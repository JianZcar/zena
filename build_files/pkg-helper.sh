#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   PKGS_TO_INSTALL=( pkg1 pkg2 @groupname ... )
#   ./pkg-helper.sh install PKGS_TO_INSTALL
#
#   PKGS_TO_UNINSTALL=( pkg1 pkg2 )
#   ./pkg-helper.sh uninstall PKGS_TO_UNINSTALL

ACTION="$1"
VAR_NAME="$2"

if [[ "$ACTION" != "install" && "$ACTION" != "uninstall" ]]; then
    echo "Usage: $0 install|uninstall VAR_NAME"
    exit 1
fi

PKGS=("${!VAR_NAME[@]}")

if [[ ${#PKGS[@]} -eq 0 ]]; then
    echo "No packages found in $VAR_NAME"
    exit 1
fi

if [[ "$ACTION" == "install" ]]; then
    dnf5 install -y "${PKGS[@]}"
else
    dnf5 remove -y "${PKGS[@]}"
fi
