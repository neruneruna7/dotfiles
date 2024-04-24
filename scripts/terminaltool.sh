# homebrewのインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

exec $SHELL

# fuzzy finderのインストール
brew install fzf

# naviのインストール
brew install navi

# zoxideのインストール
# curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
cargo binstall zoxide --locked

