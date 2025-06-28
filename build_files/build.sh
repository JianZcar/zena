#!/bin/bash

set -ouex pipefail

shopt -s nullglob

PKGS_TO_INSTALL=(
  tmux
  nvim
  btop
)

PKGS_TO_UNINSTALL=(
  firefox
  firefox-langpacks
  htop
)

/ctx/00-repos.sh
/ctx/01-kernel.sh
/ctx/02-nvidia.sh
/ctx/03-patches.sh

# this installs a package from fedora repos
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi

systemctl enable podman.socket
