#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Define repositories and the packages to be swapped from them
declare -A PKGS_TO_SWAP=(
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite"]="wireplumber"
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite-multilib"]="pipewire bluez xorg-x11-server-Xwayland mutter"
    ["terra-extras"]="switcheroo-control gnome-shell"
    ["terra-mesa"]="mesa-filesystem"
    ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd"
)

# Swap packages from the specified repositories
for repo in "${!PKGS_TO_SWAP[@]}"; do
    dnf5 -y distro-sync --repo="$repo" ${PKGS_TO_SWAP[$repo]} --allowerasing
done
unset -v PKGS_TO_SWAP repo package

sed -i 's|grub_probe} --target=device /`|grub_probe} --target=device /sysroot`|g' /usr/bin/grub2-mkconfig

# Patch rtkit
sed -i 's|^ExecStart=.*|ExecStart=/usr/libexec/rtkit-daemon --no-canary|' /usr/lib/systemd/system/rtkit-daemon.service

sed -i 's/balanced=balanced$/balanced=balanced-bazzite/' /etc/tuned/ppd.conf
sed -i 's/performance=throughput-performance$/performance=throughput-performance-bazzite/' /etc/tuned/ppd.conf
sed -i 's/balanced=balanced-battery$/balanced=balanced-battery-bazzite/' /etc/tuned/ppd.conf

# echo 'export PATH=/usr/lib/opentabletdriver:$PATH' | sudo tee /etc/profile.d/opentabletdriver.sh

ln -s /usr/bin/true /usr/bin/pulseaudio

echo "::endgroup::"
