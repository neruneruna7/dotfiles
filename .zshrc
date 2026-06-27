# starship用の設定
eval "$(starship init zsh)"
# fzf
source <(fzf --zsh)
# zoxide
eval "$(zoxide init zsh)"


. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# nodebrewのパスを通す
export PATH=$HOME/.nodebrew/current/bin:$PATH

eval "$(direnv hook zsh)"

# # Zshがインタラクティブシェルとして起動しているか確認
# if [[ $- == *i* ]]; then
#   # インタラクティブシェルの場合のみnushellを起動
#   exec nu
# fi

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/kino/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# if [ -z "$SSH_AUTH_SOCK" ]; then
# #   eval "$(ssh-agent -s)" >/dev/null
#   eval "$(ssh-agent -s)"
# fi
# if command -v ssh-add >/dev/null; then
# #   ssh-add --apple-load-keychain 2>/dev/null
#   ssh-add --apple-load-keychain 2
# fi

# uvでインストールしたコマンドのパスを通す
export PATH="$HOME/.local/bin:$PATH"

:
# opendjk
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kino/workspace/install/gcloud/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kino/workspace/install/gcloud/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kino/workspace/install/gcloud/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kino/workspace/install/gcloud/google-cloud-sdk/completion.zsh.inc'; fi


export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# codec cli でプロンプト入力時にhelixを使えるようにするための設定
export VISUAL="hx"
export EDITOR="hx"

# codex のプロファイル切り替え
alias codex-w='CODEX_HOME=$HOME/.codex-work codex'
alias codex-p='CODEX_HOME=$HOME/.codex-personal codex'
# codex 直実行を禁止
codex() {
  echo "codex は直接起動しないでください。"
  echo ""
  echo "使用可能:"
  echo "  codex-work      (仕事用)"
  echo "  codex-personal  (個人用)"
  return 1
}
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# >>> microsandbox >>>
export PATH="$HOME/.microsandbox/bin:$PATH"
export DYLD_LIBRARY_PATH="$HOME/.microsandbox/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
# <<< microsandbox <<<

# zellijのエイリアス
alias zj='zellij'


setopt allexport
source ~/dotfiles/.env.Secrets
unsetopt allexport
