#!/usr/bin/env bash
# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please run scripts/brew.sh first."
    exit 1
fi

brew update
brew upgrade

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

for installer in "${script_dir}/brew_pack/"*.sh; do
    if [ -f "${installer}" ]; then
        echo "--- Installing packages from ${installer} ---"
        bash "${installer}"
    fi
done