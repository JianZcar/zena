#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   PKGS_TO_INSTALL=( pkg1 pkg2 @groupname ... )
#   ./pkg-helper.sh install PKGS_TO_INSTALL
#
#   PKGS_TO_UNINSTALL=( pkg1 pkg2 )
#   ./pkg-helper.sh uninstall PKGS_TO_UNINSTALL

ACTION="$1"
shift

if [[ "$ACTION" == "install" ]]; then
    dnf5 install -y "$@"
elif [[ "$ACTION" == "uninstall" ]]; then
    dnf5 remove -y "$@"
else
    echo "Usage: $0 install|uninstall packages..."
    exit 1
fi
