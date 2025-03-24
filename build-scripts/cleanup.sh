#!/usr/bin/bash
set -eoux pipefail

echo "::group::===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

dnf5 clean all
rm -rf /tmp/* || true

ostree container commit
