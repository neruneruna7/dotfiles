use assert_cmd::Command;
use predicates::prelude::*;
use std::fs;
use tempfile::tempdir;

fn dotfiles_cmd() -> Command {
    Command::cargo_bin("dotfiles").unwrap()
}

fn write_config(root: &std::path::Path) {
    fs::write(
        root.join("dotfiles.toml"),
        r#"
version = 1

[policy]
default_mapping = "mirror-home"
link_kind = "file"
"#,
    )
    .unwrap();
}

fn write_config_with_ignore(root: &std::path::Path, ignored: &str) {
    fs::write(
        root.join("dotfiles.toml"),
        format!(
            r#"
version = 1

[policy]
default_mapping = "mirror-home"
link_kind = "file"
ignore = ["{ignored}"]
"#
        ),
    )
    .unwrap();
}

#[test]
fn plan_prints_change_plan() {
    let temp = tempdir().unwrap();
    let root = temp.path().join("dotfiles");
    let home = temp.path().join("home");
    fs::create_dir_all(root.join(".config/helix")).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::write(root.join(".config/helix/config.toml"), "").unwrap();
    write_config(&root);

    dotfiles_cmd()
        .args([
            "--home",
            home.to_str().unwrap(),
            "--root",
            root.to_str().unwrap(),
            "plan",
        ])
        .assert()
        .success()
        .stdout(predicate::str::contains("CREATE"));
}

#[test]
fn plan_honors_ignore_from_dotfiles_toml() {
    let temp = tempdir().unwrap();
    let root = temp.path().join("dotfiles");
    let home = temp.path().join("home");
    fs::create_dir_all(root.join(".local/state")).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::write(root.join(".local/state/app.log"), "").unwrap();
    write_config_with_ignore(&root, ".local/**");

    dotfiles_cmd()
        .args([
            "--home",
            home.to_str().unwrap(),
            "--root",
            root.to_str().unwrap(),
            "plan",
        ])
        .assert()
        .success()
        .stdout(predicate::str::is_empty());
}

#[test]
fn apply_dry_run_does_not_change_file_system() {
    let temp = tempdir().unwrap();
    let root = temp.path().join("dotfiles");
    let home = temp.path().join("home");
    fs::create_dir_all(&root).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::write(root.join(".a"), "").unwrap();
    write_config(&root);

    dotfiles_cmd()
        .args([
            "--home",
            home.to_str().unwrap(),
            "--root",
            root.to_str().unwrap(),
            "apply",
            "--dry-run",
        ])
        .assert()
        .success();

    assert!(!home.join(".a").exists());
}

#[test]
fn status_prints_link_status() {
    let temp = tempdir().unwrap();
    let root = temp.path().join("dotfiles");
    let home = temp.path().join("home");
    fs::create_dir_all(&root).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::write(root.join(".a"), "").unwrap();
    write_config(&root);

    dotfiles_cmd()
        .args([
            "--home",
            home.to_str().unwrap(),
            "--root",
            root.to_str().unwrap(),
            "status",
        ])
        .assert()
        .success()
        .stdout(predicate::str::contains("missing"));
}

#[test]
fn clean_removes_only_safe_unmanaged_links() {
    let temp = tempdir().unwrap();
    let root = temp.path().join("dotfiles");
    let home = temp.path().join("home");
    fs::create_dir_all(&root).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::write(root.join(".old"), "").unwrap();
    fs::write(home.join(".regular"), "keep").unwrap();
    std::os::unix::fs::symlink(root.join(".old"), home.join(".old")).unwrap();
    write_config_with_ignore(&root, ".old");

    dotfiles_cmd()
        .args([
            "--home",
            home.to_str().unwrap(),
            "--root",
            root.to_str().unwrap(),
            "clean",
        ])
        .assert()
        .success();

    assert!(!home.join(".old").exists());
    assert_eq!(fs::read_to_string(home.join(".regular")).unwrap(), "keep");
}

#[test]
fn invalid_config_exits_non_zero() {
    let temp = tempdir().unwrap();
    let root = temp.path().join("dotfiles");
    let home = temp.path().join("home");
    fs::create_dir_all(&root).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::write(root.join("dotfiles.toml"), "version = 2").unwrap();

    dotfiles_cmd()
        .args([
            "--home",
            home.to_str().unwrap(),
            "--root",
            root.to_str().unwrap(),
            "plan",
        ])
        .assert()
        .failure();
}
