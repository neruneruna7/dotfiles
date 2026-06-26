use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};

use crate::apply::{self, CleanAction};
use crate::config;
use crate::link_spec::{self, LinkSpec};
use crate::planner;

/// コマンドライン引数の定義である。
///
/// `--home` と `--root` は統合テストで実 HOME を触らないためにも使う。
#[derive(Debug, Parser)]
#[command(name = "dotfiles")]
#[command(about = "Safely manage dotfile symlinks")]
pub struct Cli {
    #[arg(long, global = true)]
    pub home: Option<PathBuf>,

    #[arg(long, global = true)]
    pub root: Option<PathBuf>,

    #[command(subcommand)]
    pub command: Command,
}

/// サブコマンドの定義である。
#[derive(Debug, Subcommand)]
pub enum Command {
    Plan,
    Apply {
        #[arg(long)]
        dry_run: bool,
    },
    Status,
    Clean {
        #[arg(long)]
        dry_run: bool,
    },
}

/// 実プロセスの引数を読み、CLI を実行する。
pub fn run() -> Result<()> {
    run_with(Cli::parse())
}

/// パース済み CLI を実行する。
///
/// 依存する HOME と root を引数で差し替えられるため、統合テストでも実ユーザーの
/// HOME を変更しない。
pub fn run_with(cli: Cli) -> Result<()> {
    let home = cli.home.map_or_else(default_home, Ok)?;
    let root = cli.root.unwrap_or_else(|| home.join("dotfiles"));
    let specs = load_specs(&root, &home)?;
    let plan = planner::plan(&specs, &root).context("failed to generate plan")?;

    match cli.command {
        Command::Plan => print_if_not_empty(&planner::format_plan(&plan, &home, &root)),
        Command::Apply { dry_run } => {
            print_if_not_empty(&planner::format_plan(&plan, &home, &root));
            if !dry_run {
                apply::apply_plan(&plan).context("failed to apply plan")?;
            }
        }
        Command::Status => print_if_not_empty(&planner::format_status(&plan, &home, &root)),
        Command::Clean { dry_run } => {
            let actions =
                apply::plan_clean(&home, &root, &specs).context("failed to plan clean")?;
            print_if_not_empty(&format_clean(&actions, &home));
            if !dry_run {
                apply::apply_clean(&actions).context("failed to clean links")?;
            }
        }
    }
    Ok(())
}

fn default_home() -> Result<PathBuf> {
    std::env::var_os("HOME")
        .map(PathBuf::from)
        .context("HOME is not set")
}

fn load_specs(root: &Path, home: &Path) -> Result<Vec<LinkSpec>> {
    let config_path = root.join("dotfiles.toml");
    let config = if config_path.exists() {
        config::load_config(&config_path).context("failed to load dotfiles.toml")?
    } else {
        config::default_config()
    };
    link_spec::generate_link_specs(&config, root, home).context("failed to generate link specs")
}

fn print_if_not_empty(output: &str) {
    if !output.is_empty() {
        println!("{output}");
    }
}

fn format_clean(actions: &[CleanAction], home: &Path) -> String {
    actions
        .iter()
        .filter_map(|action| match action {
            CleanAction::RemoveSymlink(path) => {
                Some(format!("REMOVE  {}", display_home(path, home)))
            }
            CleanAction::Keep(_) => None,
        })
        .collect::<Vec<_>>()
        .join("\n")
}

fn display_home(path: &Path, home: &Path) -> String {
    path.strip_prefix(home)
        .map(|relative| format!("~/{}", relative.display()))
        .unwrap_or_else(|_| path.display().to_string())
}
