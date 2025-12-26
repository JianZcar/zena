#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

coprs=(
  bieszczaders/kernel-cachyos

  yalter/niri
  ulysg/xwayland-satellite
  avengemedia/danklinux
  avengemedia/dms-git
)

repos=(
  https://negativo17.org/repos/fedora-multimedia.repo
)

mkdir -p /var/roothome
dnf5 -y install dnf5-plugins
echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf

for copr in "${coprs[@]}"; do
  echo "Enabling copr: $copr"
  dnf5 -y copr enable "$copr"
done

for repo in "${repos[@]}"; do
    dnf5 -y config-manager addrepo --from-repofile="$repo"
done

echo "priority=1" | sudo tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri.repo
echo "priority=2" | sudo tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo

echo "::endgroup::"
