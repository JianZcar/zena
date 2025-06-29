#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

PKGS_TO_INSTALL=(
    gamescope.x86_64
    gamescope-shaders
    dbus-x11
    libFAudio.x86_64
    libFAudio.i686
    latencyflex-vulkan-layer
    vkBasalt.x86_64
    vkBasalt.i686
    mangohud.x86_64
    mangohud.i686
    libobs_vkcapture.x86_64
    libobs_glcapture.x86_64
    libobs_vkcapture.i686
    libobs_glcapture.i686
    VK_hdr_layer
)

PKGS_TO_UNINSTALL=(
    gamemode
)

dnf5 -y swap --repo copr:copr.fedorainfracloud.org:bazzite-org:bazzite \
    ibus ibus

dnf5 versionlock add ibus

# Install packages from fedora repos
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

dnf5 -y --setopt=install_weak_deps=False install \
    steam \
    lutris

# Uninstall packages
if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi

curl -Lo /tmp/latencyflex.tar.xz "$(curl -s https://api.github.com/repos/ishitatsuyuki/LatencyFleX/releases/latest | jq -r '.assets[] | select(.name| test(".*\\.tar\\.xz$")).browser_download_url')"

mkdir -p /tmp/latencyflex
tar --no-same-owner --no-same-permissions --no-overwrite-dir --strip-components 1 -xvf /tmp/latencyflex.tar.xz -C /tmp/latencyflex
rm -f /tmp/latencyflex.tar.xz

mkdir -p /usr/lib64/latencyflex
cp -r /tmp/latencyflex/wine/usr/lib/wine/* /usr/lib64/latencyflex/

curl -Lo /usr/bin/latencyflex https://raw.githubusercontent.com/bazzite-org/LatencyFleX-Installer/main/install.sh
chmod +x /usr/bin/latencyflex

curl -Lo /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x /usr/bin/winetricks

echo "::endgroup::"
