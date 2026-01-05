#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  nvidia-driver-cuda
  libnvidia-fbc
  libva-nvidia-driver
  nvidia-driver
  nvidia-modprobe
  nvidia-persistenced
  nvidia-settings
)

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"

dnf5 config-manager setopt "*rpmfusion*".enabled=0
dnf5 config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf5 config-manager setopt fedora-nvidia.enabled=0
sed -i '/^enabled=/a\priority=90' /etc/yum.repos.d/fedora-nvidia.repo

dnf5 -y install --enablerepo=fedora-nvidia akmod-nvidia
mkdir -p /var/tmp # for akmods
chmod 1777 /var/tmp
dnf5 -y install gcc-c++
akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"
cat /var/cache/akmods/nvidia/*.failed.log || true

dnf5 -y install --enablerepo=fedora-nvidia "${packages[@]}"

dnf5 config-manager addrepo --from-repofile=https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
dnf5 config-manager setopt nvidia-container-toolkit.enabled=0
dnf5 config-manager setopt nvidia-container-toolkit.gpgcheck=1

dnf5 -y install --enablerepo=nvidia-container-toolkit \
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

systemctl enable nvctk-cdi.service
systemctl mask akmods-keygen@akmods-keygen.service
systemctl mask akmods-keygen.target

preset_file="/usr/lib/systemd/system-preset/01-zena.preset"
touch "$preset_file"
echo "enable nvctk-cdi.service" >> "$preset_file"

echo "::endgroup::"
