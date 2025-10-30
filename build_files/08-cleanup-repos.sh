#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +

echo "::endgroup::"
