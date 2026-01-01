#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  kernel-cachyos-lto
  kernel-cachyos-lto-devel-matched
  kernel-cachyos-lto-nvidia-open
)

dnf5 -y remove --no-autoremove \
  kernel kernel-core \
  kernel-modules kernel-modules-core \
  kernel-modules-extra kernel-tools \
  kernel-tools-libs

TMPDIR=$(mktemp -d)
pushd "$TMPDIR"

dnf5 download --arch x86_64 --resolve --destdir "$TMPDIR" "${packages[@]}"
rpm -U --noscripts --notriggers *.rpm

popd
rm -rf "$TMPDIR"

rpm --rebuilddb
dnf5 clean all
dnf5 makecache
dnf5 check
dnf5 distro-sync

dnf5 versionlock add "${packages[@]}"

sed -i 's/omit_drivers/force_drivers/g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's/ nvidia / i915 amdgpu nvidia /g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

KVER=$(ls /usr/lib/modules | head -n1)
echo "Building initramfs for kernel version: $KVER"

if [ ! -d "/usr/lib/modules/$KVER" ]; then
  echo "Error: modules missing for kernel $KVER"
  exit 1
fi

depmod -a "$KVER"

/usr/bin/dracut \
  --no-hostonly \
  --kver "$KVER" \
  --reproducible \
  --zstd -v \
  --add ostree --add fido2 \
  -f "/usr/lib/modules/$KVER/initramfs.img"

chmod 0600 "/usr/lib/modules/$KVER/initramfs.img"


echo "::endgroup::"
