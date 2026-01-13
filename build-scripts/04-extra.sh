#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  fastfetch
  gh

  bazaar
  firewall-config
  ghostty
  nautilus
  nautilus-python

  v4l2loopback
)
dnf5 -y install "${packages[@]}"
dnf5 -y upgrade nautilus-python --releasever=44

# Install install_weak_deps=false
packages=(
)
# dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
)
# dnf5 -y remove "${packages[@]}"

dconf update
# Patch ghostty to work well with "open in terminal"
rm /usr/share/nautilus-python/extensions/ghostty.py
sed -i 's|^Exec=/usr/bin/ghostty --gtk-single-instance=true$|Exec=/usr/local/bin/ghostty-pwd|' \
  /usr/share/applications/com.mitchellh.ghostty.desktop

echo "::endgroup::"
