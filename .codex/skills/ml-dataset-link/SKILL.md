---
name: ml-dataset-link
description: Use when a machine-learning project should reuse a dataset directory from /Users/kino/workspace/datasets-ml through a symbolic link. The skill includes a bundled executable for creating the link.
---

# ML Dataset Link

Use this skill when a machine-learning project needs a dataset already stored under `/Users/kino/workspace/datasets-ml/`. Reusing that directory through a symbolic link avoids keeping another dataset copy in the project.

## Workflow

1. Identify the exact dataset directory name under `/Users/kino/workspace/datasets-ml/`.
2. Determine the exact link path from the user's request or the project's existing data-loading configuration. Do not invent a project path when the intended location is unclear.
3. Invoke `scripts/dataset-link` from the installed Skill directory. Resolve that directory under `$CODEX_HOME/skills/ml-dataset-link`, or under `~/.codex/skills/ml-dataset-link` when `CODEX_HOME` is unset. Pass the dataset directory name and link path as two separate arguments. In this repository, the Cargo Make wrapper calls the repository-local copy of the same helper:

   ```sh
   cargo make dataset-link <dataset-directory-name> <link-path>
   ```

4. Confirm the resulting path is a symbolic link to the selected shared dataset and that the project uses that path.

## Behavior and limits

- The source must be an existing directory directly under `/Users/kino/workspace/datasets-ml/`.
- The second argument is the exact path to create. Relative paths resolve from the current working directory.
- The destination parent directory must already exist.
- Existing files, directories, and symbolic links are never replaced. The helper also detects dangling symbolic links.
- The helper only creates a symbolic link. It does not download, copy, move, delete, or transform dataset files.
- If the requested dataset is absent from the shared directory, report that fact and use the project's existing dataset setup instead of guessing another source.

## Bundled implementation

The Rust source is in `src/main.rs`; the executable is `scripts/dataset-link`. The executable is a release build for the machine architecture on which it was built. If it is missing or incompatible, rebuild it from the Skill directory with `cargo build --release`, copy `target/release/dataset-link` to `scripts/dataset-link`, make it executable, and remove the Cargo `target/` directory so no debug or intermediate binaries remain.
