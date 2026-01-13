#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  fastfetch
  gh

  bazaar
  firewall-config

  foot
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

echo "::endgroup::"
