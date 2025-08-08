#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

PKGS_TO_INSTALL=(
  git
  flatpak
  
  # Groups
  @base-graphical
  @core
  @hardware-support
  @multimedia
  @networkmanager-submodules
  @printing
  @fonts
  @gnome-desktop
  @workstation-product

  # WM
  niri

  # Development
  nvim
  ripgrep
  tree-sitter
  udica

  # Shell & Dotfiles
  fish
  stow

  # Fonts
  nerd-fonts
  fira-code-fonts

  # System Utilities
  btop
  fastfetch
  gum
  p7zip
  p7zip-plugins
  rar

  # File System & Storage
  btrfs-assistant # BTRFS GUI tool
  duperemove
  snapper # BTRFS snapshot management

  # Hardware & Drivers
  ddcutil # DDC/CI control for monitors
  i2c-tools
  lm_sensors

  # Display & Graphics
  cage # Wayland compositor for single applications
  vulkan-tools
  wlr-randr # Wayland output management

  # Multimedia & Audio
  pipewire-alsa.i686

  # Networking
  tailscale

  # Virtualization
  edk2-ovmf # UEFI firmware for QEMU
  virglrenderer
  virt-viewer
  libvirt
  qemu

  # GNOME
  gnome-randr-rust
  gnome-shell-extension-appindicator
  gnome-shell-extension-blur-my-shell
  gnome-shell-extension-burn-my-windows
  gnome-shell-extension-caffeine
  gnome-shell-extension-hotedge
  gnome-shell-extension-just-perfection
  gnome-shell-extension-supergfxctl-gex

  # Miscellaneous
  ublue-brew
  ublue-os-media-automount-udev
  cpulimit
  yq
  lsb_release
  openssh-askpass
  wmctrl
  yad # Dialogs for shell scripts
)

PKGS_TO_UNINSTALL=(
  htop
  gnome-classic-session
  gnome-tour
  gnome-extensions-app
  gnome-system-monitor
  gnome-initial-setup
  gnome-browser-connector
  gnome-shell-extension-background-logo
  gnome-shell-extension-apps-menu
)

/ctx/pkg-helper.sh install "${PKGS_TO_INSTALL[@]}"
/ctx/pkg-helper.sh uninstall "${PKGS_TO_UNINSTALL[@]}"

# Install Gnome extensions
git clone https://github.com/JianZcar/light-shell-plus.git /usr/share/gnome-shell/extensions/light-shell-plus@jianzcar.github \
  && rm -rf /usr/share/gnome-shell/extensions/light-shell-plus@jianzcar.github/.git

git clone https://github.com/JianZcar/peek-top-bar.git /usr/share/gnome-shell/extensions/peek-top-bar@jianzcar.github \
  && rm -rf /usr/share/gnome-shell/extensions/peek-top-bar@jianzcar.github/.git

git clone https://github.com/JianZcar/static-bg.git /usr/share/gnome-shell/extensions/static-bg@jianzcar.github \
  && rm -rf /usr/share/gnome-shell/extensions/static-bg@jianzcar.github/.git

ctx/install-gnome-extension.sh ideapad@laurento.frittella
ctx/install-gnome-extension.sh accent-directories@taiwbi.com
ctx/install-gnome-extension.sh wireless-hid@chlumskyvaclav.gmail.com
ctx/install-gnome-extension.sh gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com
ctx/install-gnome-extension.sh window-centering@hnjjhmtr27
ctx/install-gnome-extension.sh splashindicator@ochi12.github.com
ctx/install-gnome-extension.sh disable-workspace-switcher-overlay@cleardevice

# MoreWaita Icons
git clone https://github.com/somepaulo/MoreWaita.git /tmp/MoreWaita >/dev/null 2>&1 && \
bash /tmp/MoreWaita/install.sh >/dev/null 2>&1

for i in {1..5}; do
  dnf5 -y install "$(curl -s https://api.github.com/repos/bazzite-org/cicpoffs/releases/latest | jq -r '.assets[] | select(.name|test(".*rpm$")) | .browser_download_url')" && break || sleep 5
done

for i in {1..5}; do
  dnf5 -y install "$(curl -s https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest | jq -r '.assets[] | select(.name|test(".*rpm$")) | .browser_download_url')" && break || sleep 5
done

sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher

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
