#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
mkdir -p /var/roothome


dnf5 -y install dnf5-plugins
echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf

coprs=(
    ublue-os/packages
    ublue-os/flatpak-test

    bieszczaders/kernel-cachyos
    yalter/niri-git
    ulysg/xwayland-satellite
    avengemedia/danklinux
    avengemedia/dms-git
    trixieua/morewaita-icon-theme
    che/nerd-fonts
)

for copr in "${coprs[@]}"; do
    echo "Enabling copr: $copr"
    dnf5 -y copr enable "$copr"
done

repos=(
    https://negativo17.org/repos/fedora-multimedia.repo
)

# Loop and add repos
for repo in "${repos[@]}"; do
    dnf5 -y config-manager addrepo --from-repofile="$repo"
done

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
echo "priority=1" | sudo tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
echo "priority=2" | sudo tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
