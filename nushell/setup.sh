# bashからnushellのdotfilesを設定するためのスクリプト
# ...existing code...

# Nushell設定のセットアップ
mkdir -p ~/.config/nushell
ln -sf ~/dotfiles/nushell/config.nu ~/.config/nushell/config.nu
ln -sf ~/dotfiles/nushell/env.nu ~/.config/nushell/env.nu
# ...existing code...

# こっちのが新しいっぽい？
ln -sf ~/dotfiles/nushell/config.nu ~/Library/Application\ Support/nushell/config.nu
ln -sf ~/dotfiles/nushell/env.nu ~/Library/Application\ Support/nushell/env.nu
