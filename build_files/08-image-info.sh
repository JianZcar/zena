#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
DATE=$(date +%Y%m%d)

echo "zena" | tee "/etc/hostname"

sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Zena\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Zena ${RELEASE}.${DATE}\"|
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="Zena"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg
echo "::endgroup::"
