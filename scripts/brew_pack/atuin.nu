# Atuin の生成ファイルを dotfiles 側で更新する。
let init_path = ("~/dotfiles/.local/share/atuin/init.nu" | path expand)
mkdir ($init_path | path dirname)
atuin init nu | save -f $init_path
