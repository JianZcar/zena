#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  kernel-cachyos-lto
  kernel-cachyos-lto-devel-matched
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
dnf5 -y distro-sync

dnf5 versionlock add "${packages[@]}"

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"

dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager setopt fedora-nvidia.enabled=0
sed -i '/^enabled=/a\priority=90' /etc/yum.repos.d/fedora-nvidia.repo

dnf -y install --enablerepo=fedora-nvidia akmod-nvidia
mkdir -p /var/tmp # for akmods
chmod 1777 /var/tmp
dnf -y install gcc-c++
akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"
cat /var/cache/akmods/nvidia/*.failed.log || true

dnf -y install --enablerepo=fedora-nvidia \
    nvidia-driver-cuda libnvidia-fbc libva-nvidia-driver nvidia-driver nvidia-modprobe nvidia-persistenced nvidia-settings

dnf config-manager addrepo --from-repofile=https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
dnf config-manager setopt nvidia-container-toolkit.enabled=0
dnf config-manager setopt nvidia-container-toolkit.gpgcheck=1

dnf -y install --enablerepo=nvidia-container-toolkit \
    nvidia-container-toolkit

curl --retry 3 -L https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp -o nvidia-container.pp
semodule -i nvidia-container.pp
rm -f nvidia-container.pp

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
