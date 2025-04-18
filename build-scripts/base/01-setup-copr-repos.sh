#!/usr/bin/bash
set -eoux pipefail

echo "::group::===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

dnf5 -y install dnf5-plugins 
dnf5 -y downgrade dnf5 
for copr in \
  bazzite-org/bazzite \
  bazzite-org/bazzite-multilib \
  ublue-os/staging \
  ublue-os/packages \
  bazzite-org/LatencyFleX \
  bazzite-org/obs-vkcapture \
  bazzite-org/wallpaper-engine-kde-plugin \
  ycollet/audinux \
  bazzite-org/rom-properties \
  bazzite-org/webapp-manager \
  bazzite-org/vk_hdr_layer \
  hhd-dev/hhd \
  che/nerd-fonts \
  hikariknight/looking-glass-kvmfr \
  mavit/discover-overlay \
  lizardbyte/beta \
  rok/cdemu \
  rodoma92/kde-cdemu-manager \
  rodoma92/rmlint \
  ilyaz/LACT \
  tulilirockz/fw-fanctrl; do
		dnf5 -y copr enable $copr
		dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:${copr////:}.priority=98
done && unset -v copr 

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} 
dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo 
dnf5 -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 
    
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo 
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo 
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo 
dnf5 -y config-manager setopt "*bazzite*".priority=1 
dnf5 -y config-manager setopt "*akmods*".priority=2 
dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade" 
dnf5 -y config-manager setopt "terra-mesa".enabled=true 
dnf5 -y config-manager setopt "terra-nvidia".enabled=false 
eval "$(/ctx/dnf5-setopt setopt '*negativo17*' priority=4 exclude='mesa-* *xone*')" 
dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*" 
dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" 
dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell \
gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*"
