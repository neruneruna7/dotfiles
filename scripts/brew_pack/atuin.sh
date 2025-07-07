# 便利なシェル履歴
brew install atuin

# ~/.config/atuin ディレクトリを作成（存在していれば無視）
mkdir -p ~/.config/atuin

# シンボリックリンクを強制的に作成（上書き）
ln -sf ~/dotfiles/asset/atuin/config.toml ~/.config/atuin/config.toml

mkdir ~/.local/share/atuin/
nu atuin init nu | save ~/.local/share/atuin/init.nu
