#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

# Clean dnf metadata/cache
dnf5 clean all || true

# Remove everything in /tmp
rm -rf /tmp/* || true

# Remove all top-level dirs in /var except cache, log, and tmp
find /var -mindepth 1 -maxdepth 1 -type d \
    ! -name cache \
    ! -name log \
    ! -name tmp \
    -exec rm -rf {} +

# Clean out /var/cache but keep dnf and rpm-ostree dirs
find /var/cache -mindepth 1 -maxdepth 1 -type d \
    ! -name libdnf5 \
    ! -name rpm-ostree \
    -exec rm -rf {} +

# Recreate /var/tmp with correct sticky bit
mkdir -p /var/tmp
chmod 1777 /var/tmp

ostree container commit

echo "::endgroup::"
