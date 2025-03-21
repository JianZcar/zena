#!/bin/bash



set -ouex pipefail

dnf copr enable dusansimic/themes && dnf install morewaita-icon-theme
dnf copr disable dusansimic/themes

# Generate image-info.json
/ctx/build-scripts/pre/install-kernel.sh

ostree container commit
