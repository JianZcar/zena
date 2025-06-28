#!/bin/bash

echo "::group:: ===$(basename "$0")==="

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

# this installs a package from fedora repos
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi

systemctl enable podman.socket

echo "::endgroup::"
