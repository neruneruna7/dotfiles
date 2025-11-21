eval "$(/opt/homebrew/bin/brew shellenv)"
. "$HOME/.cargo/env"

# SSH_AUTH_SOCK が未設定か無効なら設定
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
  # 既存の ssh-agent のソケットを探す
  AGENT_SOCK=$(launchctl getenv SSH_AUTH_SOCK)
  if [ -n "$AGENT_SOCK" ] && [ -S "$AGENT_SOCK" ]; then
    export SSH_AUTH_SOCK=$AGENT_SOCK
  else
    # ssh-agent が動いているか確認
    AGENT_PID=$(pgrep -u "$USER" ssh-agent | head -n1)
    if [ -n "$AGENT_PID" ]; then
      # 動いていれば環境変数を探す（標準の場所はないので諦めて再起動）
      # ここでは再起動する
      eval "$(ssh-agent -s)"
      ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    else
      # 起動していなければ新規起動
      eval "$(ssh-agent -s)"
      ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    fi
  fi
fi

