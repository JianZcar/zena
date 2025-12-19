#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

sed -i -f - /usr/lib/os-release <<EOF
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Zena Arch\"|
EOF

rm -f /etc/sudoers.d/99-build-aur
userdel -r build
pacman -Rns --noconfirm base-devel paru rust

echo "::endgroup::"
