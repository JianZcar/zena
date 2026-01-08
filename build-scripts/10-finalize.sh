#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

RELEASE="$(rpm -E %fedora)"
DATE=$(date +%Y%m%d)

echo "zena" | tee "/etc/hostname"
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Zena\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Zena ${RELEASE}.${DATE}\"|
s|^HOME_URL=.*|HOME_URL=\"https://github.com/Zena-Linux/Zena\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"https://github.com/Zena-Linux/Zena/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"https://github.com/Zena-Linux/Zena/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:zena-linux:zena\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"https://github.com/Zena-Linux/Zena\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="zena"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +
rm -rf /tmp/* || true
dnf5 clean all

echo "::endgroup::"
