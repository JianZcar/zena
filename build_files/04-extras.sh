#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
    fish
    starship
    chezmoi

    switcheroo-control
    python3-gobject

    @virtualization
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
)

# dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
)
# dnf5 -y remove "${packages[@]}"

# Install Latest Stable NVIM
curl -L -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/nvim.tar.gz -C /opt
ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim

echo "::endgroup::"
