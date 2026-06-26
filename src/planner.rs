use std::fmt;
use std::path::{Path, PathBuf};

use crate::fs::{self, PathState};
use crate::link_spec::LinkSpec;

/// `apply` が実行する可能性のある変更計画である。
///
/// この型はファイルシステム変更を表すだけで、生成時には副作用を持たない。
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Plan {
    pub actions: Vec<PlanAction>,
}

/// 各 target に対する判定結果である。
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PlanAction {
    /// target が存在せず、symlink を作成できる状態である。
    CreateLink(LinkSpec),
    /// target は期待どおりの symlink であり、変更不要である。
    Noop(LinkSpec),
    /// target は通常ファイル、ディレクトリ、別リンクなどであり、自動変更しない。
    Conflict {
        spec: LinkSpec,
        reason: ConflictReason,
    },
    /// target は dotfiles root 配下を指すが、リンク先 source が存在しない。
    Stale {
        spec: LinkSpec,
        current_source: PathBuf,
    },
    /// target は symlink だが、dotfiles root 外を指している。
    ExternalLink {
        spec: LinkSpec,
        current_source: PathBuf,
    },
}

/// conflict の理由である。
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ConflictReason {
    RegularFile,
    Directory,
    Other,
    DifferentSymlink,
}

/// `status` コマンドで表示するリンク状態である。
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Status {
    Linked,
    Missing,
    Conflict,
    Stale,
    ExternalLink,
}

impl PlanAction {
    /// action が対象とする `LinkSpec` を返す。
    pub fn spec(&self) -> &LinkSpec {
        match self {
            PlanAction::CreateLink(spec)
            | PlanAction::Noop(spec)
            | PlanAction::Conflict { spec, .. }
            | PlanAction::Stale { spec, .. }
            | PlanAction::ExternalLink { spec, .. } => spec,
        }
    }

    /// action を `status` 表示用の状態へ変換する。
    pub fn status(&self) -> Status {
        match self {
            PlanAction::CreateLink(_) => Status::Missing,
            PlanAction::Noop(_) => Status::Linked,
            PlanAction::Conflict { .. } => Status::Conflict,
            PlanAction::Stale { .. } => Status::Stale,
            PlanAction::ExternalLink { .. } => Status::ExternalLink,
        }
    }
}

impl fmt::Display for Status {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Status::Linked => f.write_str("linked"),
            Status::Missing => f.write_str("missing"),
            Status::Conflict => f.write_str("conflict"),
            Status::Stale => f.write_str("stale"),
            Status::ExternalLink => f.write_str("external-link"),
        }
    }
}

/// 現在のファイルシステム状態を読み取り、変更計画を生成する。
///
/// この関数は `symlink_metadata` と `read_link` に相当する読み取りだけを行い、
/// ファイルやディレクトリを作成・削除しない。
pub fn plan(specs: &[LinkSpec], dotfiles_root: &Path) -> crate::error::Result<Plan> {
    let actions = specs
        .iter()
        .map(|spec| plan_one(spec, dotfiles_root))
        .collect::<crate::error::Result<Vec<_>>>()?;
    Ok(Plan { actions })
}

fn plan_one(spec: &LinkSpec, dotfiles_root: &Path) -> crate::error::Result<PlanAction> {
    if !spec.source.exists() && matches!(fs::path_state(&spec.target)?, PathState::Symlink(_)) {
        let PathState::Symlink(current_source) = fs::path_state(&spec.target)? else {
            unreachable!();
        };
        return Ok(PlanAction::Stale {
            spec: spec.clone(),
            current_source,
        });
    }

    match fs::path_state(&spec.target)? {
        PathState::Missing => Ok(PlanAction::CreateLink(spec.clone())),
        PathState::File => Ok(PlanAction::Conflict {
            spec: spec.clone(),
            reason: ConflictReason::RegularFile,
        }),
        PathState::Directory => Ok(PlanAction::Conflict {
            spec: spec.clone(),
            reason: ConflictReason::Directory,
        }),
        PathState::Other => Ok(PlanAction::Conflict {
            spec: spec.clone(),
            reason: ConflictReason::Other,
        }),
        PathState::Symlink(current_source)
            if fs::link_target_equals(&current_source, &spec.source, &spec.target) =>
        {
            Ok(PlanAction::Noop(spec.clone()))
        }
        PathState::Symlink(current_source)
            if current_source.starts_with(dotfiles_root) && !current_source.exists() =>
        {
            Ok(PlanAction::Stale {
                spec: spec.clone(),
                current_source,
            })
        }
        PathState::Symlink(current_source) if current_source.starts_with(dotfiles_root) => {
            Ok(PlanAction::Conflict {
                spec: spec.clone(),
                reason: ConflictReason::DifferentSymlink,
            })
        }
        PathState::Symlink(current_source) => Ok(PlanAction::ExternalLink {
            spec: spec.clone(),
            current_source,
        }),
    }
}

/// `plan` コマンド向けの表示文字列を生成する。
pub fn format_plan(plan: &Plan, home: &Path, dotfiles_root: &Path) -> String {
    plan.actions
        .iter()
        .map(|action| format_action(action, home, dotfiles_root))
        .collect::<Vec<_>>()
        .join("\n")
}

/// `status` コマンド向けの表示文字列を生成する。
pub fn format_status(plan: &Plan, home: &Path, dotfiles_root: &Path) -> String {
    plan.actions
        .iter()
        .map(|action| {
            format!(
                "{:<13} {}",
                action.status(),
                display_path(&action.spec().target, home, dotfiles_root)
            )
        })
        .collect::<Vec<_>>()
        .join("\n")
}

fn format_action(action: &PlanAction, home: &Path, dotfiles_root: &Path) -> String {
    match action {
        PlanAction::CreateLink(spec) => format!(
            "CREATE   {} -> {}",
            display_path(&spec.target, home, dotfiles_root),
            display_path(&spec.source, home, dotfiles_root)
        ),
        PlanAction::Noop(spec) => format!(
            "OK       {} already linked",
            display_path(&spec.target, home, dotfiles_root)
        ),
        PlanAction::Conflict { spec, reason } => format!(
            "CONFLICT {} {}",
            display_path(&spec.target, home, dotfiles_root),
            conflict_message(*reason)
        ),
        PlanAction::Stale { spec, .. } => format!(
            "STALE    {} points to missing source",
            display_path(&spec.target, home, dotfiles_root)
        ),
        PlanAction::ExternalLink { spec, .. } => format!(
            "CONFLICT {} points to external link",
            display_path(&spec.target, home, dotfiles_root)
        ),
    }
}

fn conflict_message(reason: ConflictReason) -> &'static str {
    match reason {
        ConflictReason::RegularFile => "exists as regular file",
        ConflictReason::Directory => "exists as directory",
        ConflictReason::Other => "exists as unsupported file type",
        ConflictReason::DifferentSymlink => "points to different source",
    }
}

fn display_path(path: &Path, home: &Path, dotfiles_root: &Path) -> String {
    if let Ok(relative) = path.strip_prefix(home) {
        format!("~/{}", relative.display())
    } else if let Ok(relative) = path.strip_prefix(dotfiles_root) {
        format!("~/dotfiles/{}", relative.display())
    } else {
        path.display().to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::link_spec::LinkKind;
    use std::fs;
    use tempfile::tempdir;

    fn spec(root: &Path, home: &Path, name: &str) -> LinkSpec {
        LinkSpec {
            source: root.join(name),
            target: home.join(name),
            kind: LinkKind::File,
        }
    }

    fn dir_spec(root: &Path, home: &Path, name: &str) -> LinkSpec {
        LinkSpec {
            source: root.join(name),
            target: home.join(name),
            kind: LinkKind::Directory,
        }
    }

    #[test]
    fn missing_target_creates_link_action() {
        let temp = tempdir().unwrap();
        let action = plan_one(
            &spec(&temp.path().join("root"), &temp.path().join("home"), ".a"),
            temp.path(),
        )
        .unwrap();
        assert!(matches!(action, PlanAction::CreateLink(_)));
    }

    #[test]
    fn expected_symlink_is_noop() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&root).unwrap();
        fs::create_dir_all(&home).unwrap();
        fs::write(root.join(".a"), "").unwrap();
        crate::fs::create_symlink(&root.join(".a"), &home.join(".a"), LinkKind::File).unwrap();

        let action = plan_one(&spec(&root, &home, ".a"), &root).unwrap();
        assert!(matches!(action, PlanAction::Noop(_)));
    }

    #[test]
    fn regular_file_target_is_conflict() {
        let temp = tempdir().unwrap();
        let home = temp.path().join("home");
        fs::create_dir_all(&home).unwrap();
        fs::write(home.join(".a"), "").unwrap();

        let action = plan_one(&spec(&temp.path().join("root"), &home, ".a"), temp.path()).unwrap();
        assert!(matches!(
            action,
            PlanAction::Conflict {
                reason: ConflictReason::RegularFile,
                ..
            }
        ));
    }

    #[test]
    fn directory_target_is_conflict() {
        let temp = tempdir().unwrap();
        let home = temp.path().join("home");
        fs::create_dir_all(home.join(".a")).unwrap();

        let action = plan_one(&spec(&temp.path().join("root"), &home, ".a"), temp.path()).unwrap();
        assert!(matches!(
            action,
            PlanAction::Conflict {
                reason: ConflictReason::Directory,
                ..
            }
        ));
    }

    #[test]
    fn symlink_to_different_source_is_conflict() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&root).unwrap();
        fs::create_dir_all(&home).unwrap();
        fs::write(root.join(".a"), "").unwrap();
        fs::write(root.join(".b"), "").unwrap();
        crate::fs::create_symlink(&root.join(".b"), &home.join(".a"), LinkKind::File).unwrap();

        let action = plan_one(&spec(&root, &home, ".a"), &root).unwrap();
        assert!(matches!(
            action,
            PlanAction::Conflict {
                reason: ConflictReason::DifferentSymlink,
                ..
            }
        ));
    }

    #[test]
    fn symlink_to_missing_dotfiles_source_is_stale() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&home).unwrap();
        crate::fs::create_symlink(&root.join(".missing"), &home.join(".a"), LinkKind::File)
            .unwrap();

        let action = plan_one(&spec(&root, &home, ".a"), &root).unwrap();
        assert!(matches!(action, PlanAction::Stale { .. }));
    }

    #[test]
    fn planner_does_not_change_file_system() {
        let temp = tempdir().unwrap();
        let home = temp.path().join("home");
        fs::create_dir_all(&home).unwrap();

        let _ = plan(&[spec(&temp.path().join("root"), &home, ".a")], temp.path()).unwrap();

        assert!(!home.join(".a").exists());
    }

    #[test]
    fn missing_target_for_directory_link_spec_creates_link_action() {
        let temp = tempdir().unwrap();
        let action = plan_one(
            &dir_spec(
                &temp.path().join("root"),
                &temp.path().join("home"),
                ".config/app",
            ),
            temp.path(),
        )
        .unwrap();

        assert!(matches!(action, PlanAction::CreateLink(_)));
    }

    #[test]
    fn expected_directory_symlink_is_noop() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(root.join(".config/app")).unwrap();
        fs::create_dir_all(home.join(".config")).unwrap();
        crate::fs::create_symlink(
            &root.join(".config/app"),
            &home.join(".config/app"),
            LinkKind::Directory,
        )
        .unwrap();

        let action = plan_one(&dir_spec(&root, &home, ".config/app"), &root).unwrap();

        assert!(matches!(action, PlanAction::Noop(_)));
    }

    #[test]
    fn existing_directory_target_for_directory_link_spec_is_conflict() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(home.join(".config/app")).unwrap();

        let action = plan_one(&dir_spec(&root, &home, ".config/app"), &root).unwrap();

        assert!(matches!(
            action,
            PlanAction::Conflict {
                reason: ConflictReason::Directory,
                ..
            }
        ));
    }

    #[test]
    fn directory_symlink_to_different_source_is_conflict() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(root.join(".config/app")).unwrap();
        fs::create_dir_all(root.join(".config/other")).unwrap();
        fs::create_dir_all(home.join(".config")).unwrap();
        crate::fs::create_symlink(
            &root.join(".config/other"),
            &home.join(".config/app"),
            LinkKind::Directory,
        )
        .unwrap();

        let action = plan_one(&dir_spec(&root, &home, ".config/app"), &root).unwrap();

        assert!(matches!(
            action,
            PlanAction::Conflict {
                reason: ConflictReason::DifferentSymlink,
                ..
            }
        ));
    }
}
