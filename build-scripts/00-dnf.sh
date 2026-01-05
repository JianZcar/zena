#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

coprs=(
  bieszczaders/kernel-cachyos-lto
  bieszczaders/kernel-cachyos-addons

  ublue-os/packages
  zhangyaoan/umu-launcher

  yalter/niri
  ulysg/xwayland-satellite
  avengemedia/danklinux
  avengemedia/dms
  sneexy/zen-browser
)

mkdir -p /var/roothome
dnf5 -y install dnf5-plugins
echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf

dnf5 -y install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 -y install --nogpgcheck --repofrompath \
  'terra,https://repos.fyralabs.com/terra$releasever' \
  terra-release{,-extras,-mesa}

for copr in "${coprs[@]}"; do
  echo "Enabling copr: $copr"
  dnf5 -y copr enable "$copr"
done

echo "priority=1" | sudo tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri.repo
echo "priority=2" | sudo tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade scx-tools scx-scheds steam python3-protobuf"
dnf5 -y config-manager setopt "terra-mesa".enabled=true
dnf5 -y config-manager setopt "*rpmfusion*".priority=4 "*rpmfusion*".exclude="mesa-*"
dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*"

dnf5 -y distro-sync

echo "::endgroup::"
