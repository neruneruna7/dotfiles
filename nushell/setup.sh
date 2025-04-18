# bashからnushellのdotfilesを設定するためのスクリプト
# ...existing code...

# Nushell設定のセットアップ
mkdir -p ~/.config/nushell
ln -sf "$PWD/nushell/config.nu" ~/.config/nushell/config.nu
ln -sf "$PWD/nushell/env.nu" ~/.config/nushell/env.nu
# ...existing code...