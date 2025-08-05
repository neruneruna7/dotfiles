# starship用の設定
export STARSHIP_CONFIG=~/dotfiles/asset/starship.toml
eval "$(starship init zsh)"
# fzf
source <(fzf --zsh)
# zoxide
eval "$(zoxide init zsh)"

export RUSTC_WRAPPER=/opt/homebrew/bin/sccache

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
