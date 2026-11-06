use std::env;
use std::ffi::{OsStr, OsString};
use std::fs;
use std::path::{Component, Path, PathBuf};
use std::process;

const DATASETS_ROOT: &str = "/Users/kino/workspace/datasets-ml";

fn main() {
    let arguments: Vec<OsString> = env::args_os().collect();

    if arguments.len() != 3 {
        eprintln!("Usage: dataset-link <dataset-directory-name> <link-path>");
        process::exit(2);
    }

    let Some(dataset_name) = arguments[1].to_str() else {
        eprintln!("dataset-link: dataset directory name must be valid UTF-8");
        process::exit(2);
    };
    let link_path = PathBuf::from(&arguments[2]);

    match create_dataset_link(Path::new(DATASETS_ROOT), dataset_name, &link_path) {
        Ok(target) => {
            let source = Path::new(DATASETS_ROOT).join(dataset_name);
            println!(
                "Created symlink: {} -> {}",
                target.display(),
                source.display()
            );
        }
        Err(message) => {
            eprintln!("dataset-link: {message}");
            process::exit(1);
        }
    }
}

fn create_dataset_link(
    datasets_root: &Path,
    dataset_name: &str,
    link_path: &Path,
) -> Result<PathBuf, String> {
    if !is_single_directory_name(dataset_name) {
        return Err("dataset name must be a single directory name".to_owned());
    }

    let source = datasets_root.join(dataset_name);
    let source_metadata = fs::metadata(&source).map_err(|error| {
        format!(
            "cannot access dataset directory {}: {error}",
            source.display()
        )
    })?;
    if !source_metadata.is_dir() {
        return Err(format!(
            "dataset source is not a directory: {}",
            source.display()
        ));
    }

    let target = absolute_path(link_path)?;
    match fs::symlink_metadata(&target) {
        Ok(_) => {
            return Err(format!("link path already exists: {}", target.display()));
        }
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => {}
        Err(error) => {
            return Err(format!(
                "cannot inspect link path {}: {error}",
                target.display()
            ));
        }
    }

    let parent = target
        .parent()
        .ok_or_else(|| format!("link path has no parent directory: {}", target.display()))?;
    let parent_metadata = fs::metadata(parent).map_err(|error| {
        format!(
            "cannot access link parent directory {}: {error}",
            parent.display()
        )
    })?;
    if !parent_metadata.is_dir() {
        return Err(format!(
            "link parent is not a directory: {}",
            parent.display()
        ));
    }

    create_symbolic_link(&source, &target)
        .map_err(|error| format!("cannot create link {}: {error}", target.display()))?;

    Ok(target)
}

fn is_single_directory_name(value: &str) -> bool {
    if value.is_empty() || value.contains(std::path::MAIN_SEPARATOR) {
        return false;
    }

    let mut components = Path::new(value).components();
    matches!(components.next(), Some(Component::Normal(name)) if name == OsStr::new(value))
        && components.next().is_none()
}

fn absolute_path(path: &Path) -> Result<PathBuf, String> {
    if path.is_absolute() {
        Ok(path.to_path_buf())
    } else {
        env::current_dir()
            .map(|current_directory| current_directory.join(path))
            .map_err(|error| format!("cannot determine the current directory: {error}"))
    }
}

#[cfg(unix)]
fn create_symbolic_link(source: &Path, target: &Path) -> std::io::Result<()> {
    std::os::unix::fs::symlink(source, target)
}

#[cfg(not(unix))]
fn create_symbolic_link(_source: &Path, _target: &Path) -> std::io::Result<()> {
    Err(std::io::Error::new(
        std::io::ErrorKind::Unsupported,
        "symbolic links are supported only on Unix platforms",
    ))
}

#[cfg(test)]
mod tests {
    use super::{create_dataset_link, is_single_directory_name};
    use std::fs;
    use std::path::PathBuf;
    use std::sync::atomic::{AtomicU64, Ordering};
    use std::time::{SystemTime, UNIX_EPOCH};

    static NEXT_DIRECTORY_ID: AtomicU64 = AtomicU64::new(0);

    struct TemporaryDirectory(PathBuf);

    impl TemporaryDirectory {
        fn new() -> Self {
            let timestamp = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .expect("system clock must be after the Unix epoch")
                .as_nanos();
            let id = NEXT_DIRECTORY_ID.fetch_add(1, Ordering::Relaxed);
            let path = std::env::temp_dir().join(format!(
                "ml-dataset-link-{}-{timestamp}-{id}",
                std::process::id()
            ));
            fs::create_dir(&path).expect("temporary directory must be created");
            Self(path)
        }

        fn path(&self) -> &std::path::Path {
            &self.0
        }
    }

    impl Drop for TemporaryDirectory {
        fn drop(&mut self) {
            fs::remove_dir_all(&self.0).expect("temporary directory must be removed");
        }
    }

    #[test]
    fn accepts_one_directory_name() {
        assert!(is_single_directory_name("cifar-10-batches-py"));
    }

    #[test]
    fn rejects_empty_or_multi_component_names() {
        for name in ["", ".", "..", "nested/dataset", "../outside", "/absolute"] {
            assert!(
                !is_single_directory_name(name),
                "unexpectedly accepted {name:?}"
            );
        }
    }

    #[cfg(unix)]
    #[test]
    fn creates_a_link_to_the_dataset_directory() {
        let temporary_directory = TemporaryDirectory::new();
        let datasets_root = temporary_directory.path().join("datasets");
        let project_directory = temporary_directory.path().join("project");
        let source = datasets_root.join("cifar-10");
        let target = project_directory.join("cifar-10");
        fs::create_dir_all(&source).expect("dataset directory must be created");
        fs::create_dir_all(&project_directory).expect("project directory must be created");

        let created_target = create_dataset_link(&datasets_root, "cifar-10", &target)
            .expect("link creation must succeed");

        assert_eq!(fs::read_link(&created_target).unwrap(), source);
        assert!(fs::metadata(&created_target).unwrap().is_dir());
    }

    #[test]
    fn does_not_replace_an_existing_path() {
        let temporary_directory = TemporaryDirectory::new();
        let datasets_root = temporary_directory.path().join("datasets");
        let project_directory = temporary_directory.path().join("project");
        let source = datasets_root.join("cifar-10");
        let target = project_directory.join("cifar-10");
        fs::create_dir_all(&source).expect("dataset directory must be created");
        fs::create_dir_all(&project_directory).expect("project directory must be created");
        fs::write(&target, "keep existing content").expect("existing file must be created");

        let result = create_dataset_link(&datasets_root, "cifar-10", &target);

        assert!(result.is_err());
        assert_eq!(
            fs::read_to_string(&target).unwrap(),
            "keep existing content"
        );
    }

    #[cfg(unix)]
    #[test]
    fn does_not_replace_an_existing_dangling_symlink() {
        let temporary_directory = TemporaryDirectory::new();
        let datasets_root = temporary_directory.path().join("datasets");
        let project_directory = temporary_directory.path().join("project");
        let source = datasets_root.join("cifar-10");
        let target = project_directory.join("cifar-10");
        let dangling_target = temporary_directory.path().join("missing-dataset");
        fs::create_dir_all(&source).expect("dataset directory must be created");
        fs::create_dir_all(&project_directory).expect("project directory must be created");
        std::os::unix::fs::symlink(&dangling_target, &target)
            .expect("dangling symlink must be created");

        let result = create_dataset_link(&datasets_root, "cifar-10", &target);

        assert!(result.is_err());
        assert_eq!(fs::read_link(&target).unwrap(), dangling_target);
    }

    #[test]
    fn requires_the_destination_parent_directory() {
        let temporary_directory = TemporaryDirectory::new();
        let datasets_root = temporary_directory.path().join("datasets");
        let source = datasets_root.join("cifar-10");
        let target = temporary_directory
            .path()
            .join("missing-project")
            .join("cifar-10");
        fs::create_dir_all(&source).expect("dataset directory must be created");

        assert!(create_dataset_link(&datasets_root, "cifar-10", &target).is_err());
    }

    #[test]
    fn rejects_a_file_as_the_dataset_source() {
        let temporary_directory = TemporaryDirectory::new();
        let datasets_root = temporary_directory.path().join("datasets");
        let project_directory = temporary_directory.path().join("project");
        let source = datasets_root.join("not-a-directory");
        let target = project_directory.join("not-a-directory");
        fs::create_dir_all(&datasets_root).expect("datasets root must be created");
        fs::create_dir_all(&project_directory).expect("project directory must be created");
        fs::write(&source, "not a dataset directory").expect("source file must be created");

        assert!(create_dataset_link(&datasets_root, "not-a-directory", &target).is_err());
    }
}
