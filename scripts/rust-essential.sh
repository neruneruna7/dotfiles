sudo apt update
sudo apt upgrade -y

sudo apt install build-essential
sudo apt install curl

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

sudo apt install mold

# バイナリをインストールして，インストールを高速化する
cargo install cargo-binstall

cargo install typos-cli
