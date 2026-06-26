use std::path::PathBuf;

#[derive(Debug, thiserror::Error)]
pub enum DotfilesError {
    #[error("source does not exist: {0}")]
    SourceMissing(PathBuf),

    #[error("source is a directory but link_kind is file: {0}")]
    SourceIsDirectory(PathBuf),

    #[error("target already exists and is not managed: {0}")]
    TargetConflict(PathBuf),

    #[error("duplicate target: {0}")]
    DuplicateTarget(PathBuf),

    #[error("explicit link conflicts with default link target: {0}")]
    ExplicitDefaultConflict(PathBuf),

    #[error("invalid config: {0}")]
    InvalidConfig(String),

    #[error("io error at {path}: {source}")]
    Io {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },
}

pub type Result<T> = std::result::Result<T, DotfilesError>;

pub fn invalid_config(message: impl Into<String>) -> DotfilesError {
    DotfilesError::InvalidConfig(message.into())
}
