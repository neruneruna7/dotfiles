sudo apt update
sudo apt upgrade

sudo apt install build-essential
sudo apt install curl

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

sudo apt install mold
