use std::collections::HashSet;
use std::path::{Path, PathBuf};

use crate::error::Result;
use crate::fs::{self, PathState};
use crate::link_spec::LinkSpec;
use crate::planner::{Plan, PlanAction};

/// `Plan` のうち安全に実行できる操作だけを実行する。
///
/// `CreateLink` 以外は実行しない。さらに実行直前にも target が未作成であることを
/// 再確認するため、計画生成後に通常ファイルが置かれても上書きしない。
pub fn apply_plan(plan: &Plan) -> Result<()> {
    for action in &plan.actions {
        if let PlanAction::CreateLink(spec) = action {
            create_link_if_still_missing(spec)?;
        }
    }
    Ok(())
}

fn create_link_if_still_missing(spec: &LinkSpec) -> Result<()> {
    if matches!(fs::path_state(&spec.target)?, PathState::Missing) {
        fs::create_parent_dirs(&spec.target)?;
        fs::create_symlink(&spec.source, &spec.target)?;
    }
    Ok(())
}

/// `clean` コマンドで実行または保持する対象である。
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CleanAction {
    /// HOME 側にある、管理対象外かつ dotfiles root 配下を指す symlink を削除する。
    RemoveSymlink(PathBuf),
    /// 通常ファイル、外部リンク、現在の管理対象など、削除しない対象である。
    Keep(PathBuf),
}

/// HOME 配下を調べ、削除してよい symlink だけを `RemoveSymlink` として計画する。
///
/// 通常ファイルは `Keep` になり、削除対象にはならない。
pub fn plan_clean(
    home: &Path,
    dotfiles_root: &Path,
    specs: &[LinkSpec],
) -> Result<Vec<CleanAction>> {
    let managed_targets = specs
        .iter()
        .map(|spec| spec.target.clone())
        .collect::<HashSet<_>>();
    let mut actions = Vec::new();
    visit_home(home, dotfiles_root, &managed_targets, &mut actions)?;
    actions.sort_by(|left, right| clean_path(left).cmp(clean_path(right)));
    Ok(actions)
}

/// `plan_clean` が削除可能と判断した symlink だけを削除する。
pub fn apply_clean(actions: &[CleanAction]) -> Result<()> {
    for action in actions {
        if let CleanAction::RemoveSymlink(path) = action {
            fs::remove_symlink(path)?;
        }
    }
    Ok(())
}

fn visit_home(
    dir: &Path,
    dotfiles_root: &Path,
    managed_targets: &HashSet<PathBuf>,
    actions: &mut Vec<CleanAction>,
) -> Result<()> {
    if !dir.exists() {
        return Ok(());
    }
    for entry in std::fs::read_dir(dir).map_err(|source| crate::error::DotfilesError::Io {
        path: dir.to_path_buf(),
        source,
    })? {
        let entry = entry.map_err(|source| crate::error::DotfilesError::Io {
            path: dir.to_path_buf(),
            source,
        })?;
        let path = entry.path();
        match fs::path_state(&path)? {
            PathState::Symlink(target)
                if target.starts_with(dotfiles_root) && !managed_targets.contains(&path) =>
            {
                actions.push(CleanAction::RemoveSymlink(path));
            }
            PathState::Symlink(_) | PathState::File | PathState::Other => {
                actions.push(CleanAction::Keep(path));
            }
            PathState::Directory => visit_home(&path, dotfiles_root, managed_targets, actions)?,
            PathState::Missing => {}
        }
    }
    Ok(())
}

fn clean_path(action: &CleanAction) -> &Path {
    match action {
        CleanAction::RemoveSymlink(path) | CleanAction::Keep(path) => path,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::planner::{ConflictReason, Plan};
    use std::fs;
    use tempfile::tempdir;

    fn spec(root: &Path, home: &Path, name: &str) -> LinkSpec {
        LinkSpec {
            source: root.join(name),
            target: home.join(name),
        }
    }

    #[test]
    fn create_link_makes_parent_directory() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&root).unwrap();
        fs::write(root.join(".a"), "").unwrap();
        let spec = spec(&root, &home, ".config/app");

        apply_plan(&Plan {
            actions: vec![PlanAction::CreateLink(LinkSpec {
                source: root.join(".a"),
                target: spec.target,
            })],
        })
        .unwrap();

        assert!(home.join(".config").is_dir());
    }

    #[test]
    fn create_link_makes_symlink() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&root).unwrap();
        fs::write(root.join(".a"), "").unwrap();
        let spec = spec(&root, &home, ".a");

        apply_plan(&Plan {
            actions: vec![PlanAction::CreateLink(spec.clone())],
        })
        .unwrap();

        assert!(matches!(
            crate::fs::path_state(&spec.target).unwrap(),
            PathState::Symlink(_)
        ));
    }

    #[test]
    fn noop_does_not_change_anything() {
        let temp = tempdir().unwrap();
        apply_plan(&Plan {
            actions: vec![PlanAction::Noop(LinkSpec {
                source: temp.path().join("source"),
                target: temp.path().join("target"),
            })],
        })
        .unwrap();

        assert!(!temp.path().join("target").exists());
    }

    #[test]
    fn conflict_is_not_executed() {
        let temp = tempdir().unwrap();
        let target = temp.path().join("target");
        fs::write(&target, "keep").unwrap();

        apply_plan(&Plan {
            actions: vec![PlanAction::Conflict {
                spec: LinkSpec {
                    source: temp.path().join("source"),
                    target: target.clone(),
                },
                reason: ConflictReason::RegularFile,
            }],
        })
        .unwrap();

        assert_eq!(fs::read_to_string(target).unwrap(), "keep");
    }

    #[test]
    fn apply_never_overwrites_regular_file() {
        let temp = tempdir().unwrap();
        let target = temp.path().join("target");
        fs::write(&target, "keep").unwrap();

        apply_plan(&Plan {
            actions: vec![PlanAction::CreateLink(LinkSpec {
                source: temp.path().join("source"),
                target: target.clone(),
            })],
        })
        .unwrap();

        assert_eq!(fs::read_to_string(target).unwrap(), "keep");
    }

    #[test]
    fn apply_never_removes_directory() {
        let temp = tempdir().unwrap();
        let target = temp.path().join("target");
        fs::create_dir(&target).unwrap();

        apply_plan(&Plan {
            actions: vec![PlanAction::CreateLink(LinkSpec {
                source: temp.path().join("source"),
                target: target.clone(),
            })],
        })
        .unwrap();

        assert!(target.is_dir());
    }

    #[test]
    fn clean_removes_unmanaged_symlink_into_dotfiles_root() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&root).unwrap();
        fs::create_dir_all(&home).unwrap();
        fs::write(root.join(".old"), "").unwrap();
        fs::create_dir_all(home.join(".config")).unwrap();
        fs::create_dir_all(root.join(".config")).unwrap();
        fs::write(root.join(".config/current"), "").unwrap();
        crate::fs::create_symlink(&root.join(".old"), &home.join(".old")).unwrap();

        let actions = plan_clean(&home, &root, &[spec(&root, &home, ".config/current")]).unwrap();
        apply_clean(&actions).unwrap();

        assert!(matches!(
            crate::fs::path_state(&home.join(".old")).unwrap(),
            PathState::Missing
        ));
    }

    #[test]
    fn clean_does_not_remove_regular_file() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&home).unwrap();
        fs::write(home.join(".file"), "").unwrap();

        let actions = plan_clean(&home, &root, &[]).unwrap();
        apply_clean(&actions).unwrap();

        assert!(home.join(".file").is_file());
    }

    #[test]
    fn clean_does_not_remove_symlink_outside_dotfiles_root() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        let outside = temp.path().join("outside");
        fs::create_dir_all(&home).unwrap();
        fs::write(&outside, "").unwrap();
        crate::fs::create_symlink(&outside, &home.join(".external")).unwrap();

        let actions = plan_clean(&home, &root, &[]).unwrap();
        apply_clean(&actions).unwrap();

        assert!(matches!(
            crate::fs::path_state(&home.join(".external")).unwrap(),
            PathState::Symlink(_)
        ));
    }

    #[test]
    fn clean_keeps_current_link_spec_target() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("root");
        let home = temp.path().join("home");
        fs::create_dir_all(&root).unwrap();
        fs::create_dir_all(&home).unwrap();
        fs::write(root.join(".current"), "").unwrap();
        crate::fs::create_symlink(&root.join(".current"), &home.join(".current")).unwrap();

        let actions = plan_clean(&home, &root, &[spec(&root, &home, ".current")]).unwrap();
        apply_clean(&actions).unwrap();

        assert!(matches!(
            crate::fs::path_state(&home.join(".current")).unwrap(),
            PathState::Symlink(_)
        ));
    }
}
