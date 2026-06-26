eval "$(/opt/homebrew/bin/brew shellenv)"
. "$HOME/.cargo/env"

# starship用の設定
# 設定ファイルの位置を伝える
export STARSHIP_CONFIG=~/dotfiles/asset/starship.toml

export NODEBREW_ROOT=/opt/homebrew/var/nodebrew

# uvxの設定
. "$HOME/.local/bin/env"
