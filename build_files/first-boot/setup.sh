#!/usr/sbin/bash

set -euo pipefail

FLAG_FILE="/var/lib/zena-done"
LOG_FILE="/var/lib/zena-progress.log"

cleanup() {
  (sleep 5 && rm -f "$LOG_FILE") &
}
trap cleanup EXIT

log() {
  echo "$@" | tee -a "$LOG_FILE"
}

if [ -f "$FLAG_FILE" ]; then
  exit 0
fi

log ":: Zena Setup Started"

log "[1/3] Rebasing to Zena..."
rpm-ostree rebase ostree-unverified-registry:ghcr.io/jianzcar/zena:stable >/dev/null 2>&1 || true

log "[2/3] Installing Flatpaks..."

flatpaks=(
  # System & Utilities
  com.github.tchx84.Flatseal/x86_64/stable
  com.mattjakeman.ExtensionManager/x86_64/stable
  com.ranfdev.DistroShelf/x86_64/stable
  io.github.flattool.Warehouse/x86_64/stable
  io.missioncenter.MissionCenter/x86_64/stable
  it.mijorus.gearlever/x86_64/stable
  org.virt_manager.virt-manager/x86_64/stable
  page.tesk.Refine/x86_64/stable

  # GNOME Core Apps
  org.gnome.Calculator/x86_64/stable
  org.gnome.Calendar/x86_64/stable
  org.gnome.Characters/x86_64/stable
  org.gnome.clocks/x86_64/stable
  org.gnome.Contacts/x86_64/stable
  org.gnome.font-viewer/x86_64/stable
  org.gnome.Logs/x86_64/stable
  org.gnome.Loupe/x86_64/stable
  org.gnome.NautilusPreviewer/x86_64/stable
  org.gnome.Papers/x86_64/stable
  org.gnome.Weather/x86_64/stable
  org.gnome.baobab/x86_64/stable

  # Security
  com.belmoussaoui.Authenticator/x86_64/stable
  org.gnome.World.Secrets/x86_64/stable

  # Gaming
  page.kramo.Cartridges/x86_64/stable
  com.vysp3r.ProtonPlus/x86_64/stable
  io.github.radiolamp.mangojuice/x86_64/stable

  # OBS Streaming Plugins
  com.obsproject.Studio.Plugin.Gstreamer/x86_64/stable
  com.obsproject.Studio.Plugin.GStreamerVaapi/x86_64/stable
  com.obsproject.Studio.Plugin.OBSVkCapture/x86_64/stable

  # Web Browser
  app.zen_browser.zen/x86_64/stable

  # Themes
  org.gtk.Gtk3theme.adw-gtk3/x86_64/3.22
  org.gtk.Gtk3theme.adw-gtk3-dark/x86_64/3.22

  # Runtime Extensions
  org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08
  org.freedesktop.Platform.VulkanLayer.vkBasalt/x86_64/24.08
  org.freedesktop.Platform.VulkanLayer.OBSVkCapture/x86_64/24.08
)
for app in "${flatpaks[@]}"; do
  flatpak install -y --system flathub "$app"
done

log "[3/3] Regenerating GRUB config..."
grub2-mkconfig -o /boot/grub2/grub.cfg

log ":: Setup complete"
touch "$FLAG_FILE"
