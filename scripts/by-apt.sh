#!/usr/bin/env bash

sudo apt update
sudo apt upgrade -y

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

for installer in "${script_dir}/apt_pack/"*.sh; do
    if [ -f "${installer}" ]; then
        echo "--- Installing packages from ${installer} ---"
        bash "${installer}"
    fi
done
