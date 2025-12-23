#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

sed -i -f - /etc/os-release <<EOF
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Zena Arch\"|
s|^VERSION_ID=.*|VERSION_ID=\"${VERSION_ID}\"|
EOF
cp /etc/os-release /usr/lib/os-release

mkdir -p /etc/selinux/targeted/contexts/files
touch /etc/selinux/targeted/contexts/files/file_contexts

mkdir -p /etc/selinux/
echo "SELINUX=disabled" > /etc/selinux/config

rm -f /etc/sudoers.d/99-build-aur
userdel -r build
pacman -Rns --noconfirm base-devel paru rust

echo "::endgroup::"
