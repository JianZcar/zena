#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

PKGS_TO_INSTALL=(
    # Development
    nvim
    ripgrep
    tree-sitter
    udica

    # Shell & Dotfiles
    fish
    stow

    # System Utilities
    btop
    duf
    fastfetch
    glow
    gum
    p7zip
    p7zip-plugins
    rar
    topgrade

    # File System & Storage
    btrfs-assistant # BTRFS GUI tool
    duperemove
    f3 # Flash memory tester
    lzip
    snapper # BTRFS snapshot management

    # Hardware & Drivers
    ddcutil # DDC/CI control for monitors
    i2c-tools
    input-remapper
    iwd # iNet Wireless Daemon
    libcec # HDMI CEC library
    lm_sensors

    # Display & Graphics
    cage # Wayland compositor for single applications
    extest.i686 # X extension tester
    vulkan-tools
    wlr-randr # Wayland output management
    xrandr
    xwininfo

    pipewire-alsa.i686

    # Networking
    tailscale

    # Virtualization
    edk2-ovmf # UEFI firmware for QEMU
    virglrenderer
    virt-viewer
    libvirt
    qemu

    # Miscellaneous
    ublue-brew
    ublue-os-media-automount-udev
    cpulimit
    firewall-config
    lsb_release
    openssh-askpass
    stress-ng # Stress test system
    wmctrl
)

PKGS_TO_UNINSTALL=(
)

dnf5 -y install "${PKGS_TO_INSTALL[@]}"
# dnf5 -y remove "${PKGS_TO_UNINSTALL[@]}"

for i in {1..5}; do
    dnf5 -y install "$(curl -s https://api.github.com/repos/bazzite-org/cicpoffs/releases/latest | jq -r '.assets[] | select(.name|test(".*rpm$")) | .browser_download_url')" && break || sleep 5
done

for i in {1..5}; do
    dnf5 -y install "$(curl -s https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest | jq -r '.assets[] | select(.name|test(".*rpm$")) | .browser_download_url')" && break || sleep 5
done

curl -Lo /usr/bin/installcab https://raw.githubusercontent.com/bazzite-org/steam-proton-mf-wmv/master/installcab.py
chmod +x /usr/bin/installcab

curl -Lo /usr/bin/install-mf-wmv https://github.com/bazzite-org/steam-proton-mf-wmv/blob/master/install-mf-wmv.sh
chmod +x /usr/bin/install-mf-wmv

curl -Lo /tmp/ls-iommu.tar.gz "$(curl -s https://api.github.com/repos/HikariKnight/ls-iommu/releases/latest \
    | jq -r '.assets[] | select(.name | test(".*x86_64.tar.gz$")) | .browser_download_url')"
mkdir -p /tmp/ls-iommu
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/ls-iommu.tar.gz -C /tmp/ls-iommu
cp -r /tmp/ls-iommu/ls-iommu /usr/bin/
rm -rf /tmp/ls-iommu*

SCOPEBUDDY_TAG=$(curl -s https://api.github.com/repos/HikariKnight/scopebuddy/releases/latest | jq -r '.tag_name')
curl -Lo /tmp/scopebuddy.tar.gz "https://github.com/HikariKnight/scopebuddy/archive/refs/tags/${SCOPEBUDDY_TAG}.tar.gz"
mkdir -p /tmp/scopebuddy
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/scopebuddy.tar.gz -C /tmp/scopebuddy
cp -r /tmp/scopebuddy/ScopeBuddy-*/bin/* /usr/bin/
rm -rf /tmp/scopebuddy*

echo "::endgroup::"
