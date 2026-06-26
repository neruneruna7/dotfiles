# makers s --list / cargo make s --list の出力から補完候補を作る
def "nu-complete work-projects" [] {
    let out = (
        try {
            ^makers s --list
        } catch {
            try {
                ^cargo make s --list
            } catch {
                ""
            }
        }
    )

    $out
    | lines
    | each {|line| $line | ansi strip | str trim }
    | where {|line| $line != "" }
    | where {|line| not ($line | str starts-with "[cargo-make]") }
    | where {|line| not ($line | str contains "Build Done in") }
    | each {|line|
        let cols = ($line | split row (char tab))
        if (($cols | length) >= 2) {
            {
                value: ($cols | get 0 | str trim)
                description: ($cols | get 1 | str trim)
            }
        } else {
            {
                value: $line
                description: ""
            }
        }
    }
    | uniq
}
# 既存の汎用 extern に加えて、s/e 専用 extern を定義して補完を効かせる
export extern "cargo make s" [
    project?: string@"nu-complete work-projects"
    --list(-l)
]

export extern "cargo make e" [
    project?: string@"nu-complete work-projects"
    --list(-l)
]

export extern "makers s" [
    project?: string@"nu-complete work-projects"
    --list(-l)
]

export extern "makers e" [
    project?: string@"nu-complete work-projects"
    --list(-l)
]
