use std::path::{Path, PathBuf};

use crate::error::{DotfilesError, Result};

/// symlink を辿らずに判定したパスの状態である。
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PathState {
    Missing,
    File,
    Directory,
    Symlink(PathBuf),
    Other,
}

/// パスの状態を取得する。
///
/// `metadata` ではなく `symlink_metadata` を使うため、壊れた symlink も
/// `Symlink` として扱える。
pub fn path_state(path: &Path) -> Result<PathState> {
    match std::fs::symlink_metadata(path) {
        Ok(metadata) => {
            let file_type = metadata.file_type();
            if file_type.is_symlink() {
                read_link(path).map(PathState::Symlink)
            } else if file_type.is_file() {
                Ok(PathState::File)
            } else if file_type.is_dir() {
                Ok(PathState::Directory)
            } else {
                Ok(PathState::Other)
            }
        }
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(PathState::Missing),
        Err(source) => Err(DotfilesError::Io {
            path: path.to_path_buf(),
            source,
        }),
    }
}

/// symlink のリンク先を読み取る。
pub fn read_link(path: &Path) -> Result<PathBuf> {
    std::fs::read_link(path).map_err(|source| DotfilesError::Io {
        path: path.to_path_buf(),
        source,
    })
}

/// target の親ディレクトリを作成する。
pub fn create_parent_dirs(path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(|source| DotfilesError::Io {
            path: parent.to_path_buf(),
            source,
        })?;
    }
    Ok(())
}

#[cfg(unix)]
/// Unix の symlink を作成する。
pub fn create_symlink(source: &Path, target: &Path) -> Result<()> {
    std::os::unix::fs::symlink(source, target).map_err(|source| DotfilesError::Io {
        path: target.to_path_buf(),
        source,
    })
}

#[cfg(windows)]
/// Windows のファイル symlink を作成する。
pub fn create_symlink(source: &Path, target: &Path) -> Result<()> {
    std::os::windows::fs::symlink_file(source, target).map_err(|source| DotfilesError::Io {
        path: target.to_path_buf(),
        source,
    })
}

/// symlink を削除する。
///
/// 呼び出し側が削除対象を symlink に限定する責務を持つ。
pub fn remove_symlink(path: &Path) -> Result<()> {
    std::fs::remove_file(path).map_err(|source| DotfilesError::Io {
        path: path.to_path_buf(),
        source,
    })
}

/// symlink のリンク先が期待する source と一致するかを判定する。
///
/// 相対 symlink は symlink 自身の親ディレクトリから解決して比較する。
pub fn link_target_equals(actual: &Path, expected: &Path, symlink_path: &Path) -> bool {
    let actual_absolute = if actual.is_absolute() {
        actual.to_path_buf()
    } else {
        symlink_path
            .parent()
            .map_or_else(|| actual.to_path_buf(), |parent| parent.join(actual))
    };
    actual_absolute == expected
}
