use std::collections::{HashMap, HashSet};
use std::path::{Path, PathBuf};

use crate::config::{Config, LinkKind};
use crate::discover;
use crate::error::{DotfilesError, Result};

/// 生成・検証済みのリンク仕様である。
///
/// `source` と `target` は絶対パスとして保持する。デフォルト探索から来たリンクと
/// `dotfiles.toml` の `[[links]]` から来たリンクは、ここから先では区別しない。
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct LinkSpec {
    pub source: PathBuf,
    pub target: PathBuf,
}

/// 設定とデフォルト探索結果を統合し、`LinkSpec` の集合を生成する。
///
/// 同じ target が複数の source から生成される場合は、暗黙の上書きを避けるため
/// エラーにする。
pub fn generate_link_specs(
    config: &Config,
    dotfiles_root: &Path,
    home: &Path,
) -> Result<Vec<LinkSpec>> {
    let default_relative_sources = discover::discover_files(dotfiles_root, &config.policy.ignore)?;
    let default_specs = default_relative_sources
        .into_iter()
        .map(|relative| {
            make_spec(
                dotfiles_root,
                home,
                &relative,
                &relative,
                config.policy.link_kind,
            )
        })
        .collect::<Result<Vec<_>>>()?;

    let default_targets = default_specs
        .iter()
        .map(|spec| spec.target.clone())
        .collect::<HashSet<_>>();

    let explicit_specs = config
        .links
        .iter()
        .map(|link| {
            make_spec(
                dotfiles_root,
                home,
                &link.source,
                &link.target,
                config.policy.link_kind,
            )
        })
        .collect::<Result<Vec<_>>>()?;

    for spec in &explicit_specs {
        if default_targets.contains(&spec.target) {
            return Err(DotfilesError::ExplicitDefaultConflict(spec.target.clone()));
        }
    }

    let mut specs = default_specs;
    specs.extend(explicit_specs);
    reject_duplicate_targets(&specs)?;
    specs.sort_by(|left, right| left.target.cmp(&right.target));
    Ok(specs)
}

fn make_spec(
    dotfiles_root: &Path,
    home: &Path,
    relative_source: &Path,
    target: &Path,
    link_kind: LinkKind,
) -> Result<LinkSpec> {
    let source = dotfiles_root.join(relative_source);
    let metadata = std::fs::symlink_metadata(&source)
        .map_err(|_| DotfilesError::SourceMissing(source.clone()))?;
    if link_kind == LinkKind::File && metadata.is_dir() {
        return Err(DotfilesError::SourceIsDirectory(source));
    }
    let source = absolute_path(&source)?;
    let target = if target.is_absolute() {
        target.to_path_buf()
    } else {
        home.join(target)
    };
    Ok(LinkSpec { source, target })
}

fn absolute_path(path: &Path) -> Result<PathBuf> {
    path.canonicalize().map_err(|source| DotfilesError::Io {
        path: path.to_path_buf(),
        source,
    })
}

fn reject_duplicate_targets(specs: &[LinkSpec]) -> Result<()> {
    let mut seen = HashMap::<PathBuf, PathBuf>::new();
    for spec in specs {
        if let Some(previous) = seen.insert(spec.target.clone(), spec.source.clone())
            && previous != spec.source
        {
            return Err(DotfilesError::DuplicateTarget(spec.target.clone()));
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::{Config, ConfiguredLink, DefaultMapping, LinkKind, Policy};
    use std::fs;
    use tempfile::tempdir;

    fn touch(path: &Path) {
        fs::create_dir_all(path.parent().unwrap()).unwrap();
        fs::write(path, "").unwrap();
    }

    fn config(links: Vec<ConfiguredLink>) -> Config {
        Config {
            version: 1,
            policy: Policy {
                default_mapping: DefaultMapping::MirrorHome,
                link_kind: LinkKind::File,
                ignore: Vec::new(),
            },
            links,
        }
    }

    #[test]
    fn default_mapping_generates_home_mirror_link_spec() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("dotfiles");
        let home = temp.path().join("home");
        touch(&root.join(".config/helix/config.toml"));

        let specs = generate_link_specs(&config(Vec::new()), &root, &home).unwrap();

        assert_eq!(
            specs,
            vec![LinkSpec {
                source: root
                    .join(".config/helix/config.toml")
                    .canonicalize()
                    .unwrap(),
                target: home.join(".config/helix/config.toml")
            }]
        );
    }

    #[test]
    fn explicit_links_generate_link_specs() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("dotfiles");
        let home = temp.path().join("home");
        touch(&root.join(".config/git/config"));

        let specs = generate_link_specs(
            &config(vec![ConfiguredLink {
                source: PathBuf::from(".config/git/config"),
                target: PathBuf::from(".gitconfig"),
            }]),
            &root,
            &home,
        )
        .unwrap();

        assert!(
            specs
                .iter()
                .any(|spec| spec.target == home.join(".gitconfig"))
        );
    }

    #[test]
    fn policy_ignore_excludes_default_generated_link_specs() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("dotfiles");
        let home = temp.path().join("home");
        touch(&root.join(".config/managed.toml"));
        touch(&root.join(".local/state/app.log"));

        let mut config = config(Vec::new());
        config.policy.ignore = vec![String::from(".local/**")];
        let specs = generate_link_specs(&config, &root, &home).unwrap();

        assert_eq!(specs.len(), 1);
        assert_eq!(specs[0].target, home.join(".config/managed.toml"));
    }

    #[test]
    fn explicit_link_conflicting_with_default_target_is_error() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("dotfiles");
        let home = temp.path().join("home");
        touch(&root.join(".gitconfig"));
        touch(&root.join(".config/git/config"));

        let err = generate_link_specs(
            &config(vec![ConfiguredLink {
                source: PathBuf::from(".config/git/config"),
                target: PathBuf::from(".gitconfig"),
            }]),
            &root,
            &home,
        )
        .unwrap_err();

        assert!(matches!(err, DotfilesError::ExplicitDefaultConflict(_)));
    }

    #[test]
    fn missing_explicit_source_is_error() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("dotfiles");
        fs::create_dir(&root).unwrap();
        let home = temp.path().join("home");

        let err = generate_link_specs(
            &config(vec![ConfiguredLink {
                source: PathBuf::from(".missing"),
                target: PathBuf::from(".target"),
            }]),
            &root,
            &home,
        )
        .unwrap_err();

        assert!(matches!(err, DotfilesError::SourceMissing(_)));
    }

    #[test]
    fn directory_source_is_error_when_link_kind_is_file() {
        let temp = tempdir().unwrap();
        let root = temp.path().join("dotfiles");
        fs::create_dir_all(root.join(".config/app")).unwrap();
        let home = temp.path().join("home");

        let err = generate_link_specs(
            &config(vec![ConfiguredLink {
                source: PathBuf::from(".config/app"),
                target: PathBuf::from(".config/app"),
            }]),
            &root,
            &home,
        )
        .unwrap_err();

        assert!(matches!(err, DotfilesError::SourceIsDirectory(_)));
    }
}
