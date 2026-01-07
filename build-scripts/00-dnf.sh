#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

coprs=(
  bieszczaders/kernel-cachyos-lto
  bieszczaders/kernel-cachyos-addons

  ublue-os/packages

  yalter/niri-git
  ulysg/xwayland-satellite
  avengemedia/danklinux
  avengemedia/dms-git
)

mkdir -p /var/roothome
dnf5 -y install dnf5-plugins
echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf
RELEASE=$(rpm -E %fedora)

dnf5 -y install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
  terra-release{,-extras,-mesa}

dnf5 config-manager setopt "terra.gpgkey=https://repos.fyralabs.com/terra${RELEASE}/key.asc"
dnf5 config-manager setopt "terra.gpgcheck=1"
dnf5 config-manager setopt "terra-mesa.gpgkey=https://repos.fyralabs.com/terra${RELEASE}-mesa/key.asc"
dnf5 config-manager setopt "terra-extras.gpgkey=https://repos.fyralabs.com/terra${RELEASE}-extras/key.asc"
dnf5 config-manager setopt "terra-mesa.gpgcheck=1"
dnf5 config-manager setopt "terra-extras.gpgcheck=1"

for copr in "${coprs[@]}"; do
  echo "Enabling copr: $copr"
  dnf5 -y copr enable "$copr"
  dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:${copr////:}.priority=95 ;\
done

echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
echo "priority=2" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade steam python3-protobuf"
dnf5 -y config-manager setopt "terra-mesa".enabled=true
dnf5 -y config-manager setopt "*rpmfusion*".priority=4 "*rpmfusion*".exclude="mesa-*"
dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*"

dnf5 -y distro-sync

echo "::endgroup::"
