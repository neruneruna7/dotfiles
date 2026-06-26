alias makers = cargo make
alias "carg-make make" = cargo make

export extern "cargo make" [
    task?: string@"nu-complete tasks"    # task to run
    --help(-h)                           # Print help information
    --version(-V)                        # Print version information
    --makefile: path                     # The optional toml file containing the tasks definitions
    --task(-t): string@"nu-complete tasks" # The task name to execute (can omit the flag if the task name is the last argument) [default: default]
    --profile(-p): string                # The profile name (will be converted to lower case) [default: development]
    # --profile(-p): string@"nu-complete profiles"                # The profile name (will be converted to lower case) [default: development]
    --cwd: path                          # Will set the current working directory. The search for the makefile will be from this directory if defined.
    --no-workspace                       # Disable workspace support (tasks are triggered on workspace and not on members)
    --no-on-error                        # Disable on error flow even if defined in config sections
    --allow-private                      # Allow invocation of private tasks
    --skip-init-end-tasks                # If set, init and end tasks are skipped
    --skip-tasks: string                 # Skip all tasks that match the provided regex (example: pre.*|post.*)
    --env-file: path                     # Set environment variables from provided file
    --env(-e): string                    # Set environment variables
    --loglevel(-l): string@"nu-complete loglevels"  # The log level (verbose, info, error, off) [default: info]
    --verbose(-v)                        # Sets the log level to verbose (shorthand for --loglevel verbose)
    --quiet                              # Sets the log level to error (shorthand for --loglevel error)
    --silent                             # Sets the log level to off (shorthand for --loglevel off)
    --no-color                           # Disables colorful output
    --time-summary                       # Print task level time summary at end of flow
    --experimental                       # Allows access unsupported experimental predefined tasks.
    --disable-check-for-updates          # Disables the update check during startup
    --output-format: string@"nu-complete output-format"  # The print/list steps format (some operations do not support all formats) (default, short-description, markdown, markdown-single-page, markdown-sub-section, autocomplete)
    --output-file: path                  # The list steps output file name
    --hide-uninteresting                 # Hide any minor tasks such as pre/post hooks.
    --print-steps                        # Only prints the steps of the build in the order they will be invoked but without invoking them
    --list-all-steps                     # Lists all known steps
    --list-category-steps: string        # List steps for a given category
    --diff-steps                         # Runs diff between custom flow and prebuilt flow (requires git)
]

export extern "makers" [
    task?: string@"nu-complete tasks"    # task to run
    --help(-h)                           # Print help information
    --version(-V)                        # Print version information
    --makefile: path                     # The optional toml file containing the tasks definitions
    --task(-t): string@"nu-complete tasks" # The task name to execute (can omit the flag if the task name is the last argument) [default: default]
    --profile(-p): string                # The profile name (will be converted to lower case) [default: development]
    # --profile(-p): string@"nu-complete profiles"                # The profile name (will be converted to lower case) [default: development]
    --cwd: path                          # Will set the current working directory. The search for the makefile will be from this directory if defined.
    --no-workspace                       # Disable workspace support (tasks are triggered on workspace and not on members)
    --no-on-error                        # Disable on error flow even if defined in config sections
    --allow-private                      # Allow invocation of private tasks
    --skip-init-end-tasks                # If set, init and end tasks are skipped
    --skip-tasks: string                 # Skip all tasks that match the provided regex (example: pre.*|post.*)
    --env-file: path                     # Set environment variables from provided file
    --env(-e): string                    # Set environment variables
    --loglevel(-l): string@"nu-complete loglevels"  # The log level (verbose, info, error, off) [default: info]
    --verbose(-v)                        # Sets the log level to verbose (shorthand for --loglevel verbose)
    --quiet                              # Sets the log level to error (shorthand for --loglevel error)
    --silent                             # Sets the log level to off (shorthand for --loglevel off)
    --no-color                           # Disables colorful output
    --time-summary                       # Print task level time summary at end of flow
    --experimental                       # Allows access unsupported experimental predefined tasks.
    --disable-check-for-updates          # Disables the update check during startup
    --output-format: string@"nu-complete output-format"  # The print/list steps format (some operations do not support all formats) (default, short-description, markdown, markdown-single-page, markdown-sub-section, autocomplete)
    --output-file: path                  # The list steps output file name
    --hide-uninteresting                 # Hide any minor tasks such as pre/post hooks.
    --print-steps                        # Only prints the steps of the build in the order they will be invoked but without invoking them
    --list-all-steps                     # Lists all known steps
    --list-category-steps: string        # List steps for a given category
    --diff-steps                         # Runs diff between custom flow and prebuilt flow (requires git)
]

# 指定されたTOMLファイルからタスクを再帰的に抽出する内部関数
def "get-cargo-make-tasks-recursive" [current_file: path] {
    # ファイルが存在しない場合は空リストを返して終了（ベースケース）
    if not ($current_file | path exists) {
        return []
    }

    # TOMLをパース
    let toml_data = (open $current_file)

    # 1. そのファイル内で定義されているタスクを取得
    let local_tasks = ($toml_data | get -o tasks | default {} | columns)

    # 2. extendフィールドを取得 (存在しない場合は空リスト)
    let extends_list = ($toml_data | get -o extend | default [])

    # 3. extendされた各ファイルに対して再帰的に処理
    let inherited_tasks = if ($extends_list | is-empty) {
        []
    } else {
        $extends_list | each { |ext|
            # extendのパス解決: 現在のファイルがあるディレクトリを基準にする
            # 例: tasks/build.toml が common.toml をextendする場合 -> tasks/common.toml
            let next_file_path = ($current_file | path dirname | path join $ext.path)
            
            # 再帰呼び出し
            get-cargo-make-tasks-recursive $next_file_path
        } | flatten
    }

    # ローカル定義と継承された定義を結合
    $local_tasks | append $inherited_tasks
}

# 補完用のメイン関数
def "nu-complete tasks" [] {
    # エントリーポイントとなる Makefile.toml から探索を開始
    # 最終的に重複を削除(uniq)し、ソートして返す
    get-cargo-make-tasks-recursive "Makefile.toml" | uniq | sort
}





def "nu-complete profiles" [] {
    # TODO
}

def "nu-complete loglevels" [] {
    ['verbose', 'info', 'error', 'off']
}

def "nu-complete output-format" [] {
    ['default', 'short-description', 'markdown', 'markdown-single-page', 'markdown-sub-section', 'autocomplete']
}