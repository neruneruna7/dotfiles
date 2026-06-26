use std::path::{Path, PathBuf};

use glob::Pattern;

use crate::config;
use crate::error::{DotfilesError, Result, invalid_config};

/// dotfiles root 配下から、デフォルト規則でリンク候補になる通常ファイルを探す。
///
/// ディレクトリ自体はリンク候補にしない。ディレクトリは target の親ディレクトリとして
/// `apply` 時に作成されるだけである。
pub fn discover_files(root: &Path, ignore: &[String]) -> Result<Vec<PathBuf>> {
    let mut patterns = config::default_ignore();
    patterns.extend(ignore.iter().cloned());
    let patterns = patterns
        .iter()
        .map(|pattern| {
            Pattern::new(pattern).map_err(|error| {
                invalid_config(format!("invalid ignore pattern {pattern:?}: {error}"))
            })
        })
        .collect::<Result<Vec<_>>>()?;

    let mut files = Vec::new();
    visit(root, root, &patterns, &mut files)?;
    files.sort();
    Ok(files)
}

fn visit(root: &Path, dir: &Path, patterns: &[Pattern], files: &mut Vec<PathBuf>) -> Result<()> {
    for entry in std::fs::read_dir(dir).map_err(|source| DotfilesError::Io {
        path: dir.to_path_buf(),
        source,
    })? {
        let entry = entry.map_err(|source| DotfilesError::Io {
            path: dir.to_path_buf(),
            source,
        })?;
        let path = entry.path();
        let relative = path.strip_prefix(root).map_err(|_| {
            invalid_config(format!("path escaped dotfiles root: {}", path.display()))
        })?;
        if is_ignored(relative, patterns) {
            continue;
        }
        let file_type = entry.file_type().map_err(|source| DotfilesError::Io {
            path: path.clone(),
            source,
        })?;
        if file_type.is_dir() {
            visit(root, &path, patterns, files)?;
        } else if file_type.is_file() {
            files.push(relative.to_path_buf());
        }
    }
    Ok(())
}

fn is_ignored(relative: &Path, patterns: &[Pattern]) -> bool {
    let normalized = relative.to_string_lossy();
    patterns
        .iter()
        .any(|pattern| pattern.matches_path(relative) || pattern.matches(&normalized))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::tempdir;

    fn touch(path: &Path) {
        fs::create_dir_all(path.parent().unwrap()).unwrap();
        fs::write(path, "").unwrap();
    }

    #[test]
    fn regular_files_under_dotfiles_root_are_discovered() {
        let temp = tempdir().unwrap();
        touch(&temp.path().join(".config/helix/config.toml"));

        assert_eq!(
            discover_files(temp.path(), &[]).unwrap(),
            vec![PathBuf::from(".config/helix/config.toml")]
        );
    }

    #[test]
    fn git_directory_is_ignored() {
        let temp = tempdir().unwrap();
        touch(&temp.path().join(".git/config"));

        assert!(discover_files(temp.path(), &[]).unwrap().is_empty());
    }

    #[test]
    fn dotfiles_toml_is_ignored() {
        let temp = tempdir().unwrap();
        touch(&temp.path().join("dotfiles.toml"));

        assert!(discover_files(temp.path(), &[]).unwrap().is_empty());
    }

    #[test]
    fn readme_is_ignored() {
        let temp = tempdir().unwrap();
        touch(&temp.path().join("README.md"));

        assert!(discover_files(temp.path(), &[]).unwrap().is_empty());
    }

    #[test]
    fn directories_are_not_link_targets() {
        let temp = tempdir().unwrap();
        fs::create_dir(temp.path().join(".config")).unwrap();

        assert!(discover_files(temp.path(), &[]).unwrap().is_empty());
    }

    #[test]
    fn configured_ignore_patterns_are_excluded() {
        let temp = tempdir().unwrap();
        touch(&temp.path().join(".local/state/app.log"));

        assert!(
            discover_files(temp.path(), &[String::from(".local/**")])
                .unwrap()
                .is_empty()
        );
    }
}
