#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
    ############################
    # WIFI / WIRELESS FIRMWARE #
    ############################
    NetworkManager-wifi
    atheros-firmware
    brcmfmac-firmware
    iwlegacy-firmware
    iwlwifi-dvm-firmware
    iwlwifi-mvm-firmware
    mt7xxx-firmware
    nxpwireless-firmware
    realtek-firmware
    tiwilink-firmware

    ############################
    # AUDIO / SOUND FIRMWARE   #
    ############################
    alsa-firmware
    alsa-sof-firmware
    alsa-tools-firmware
    intel-audio-firmware

    ############################
    # SYSTEM / CORE UTILITIES  #
    ############################
    audit
    audispd-plugins
    cifs-utils
    firewalld
    fuse
    fuse-common
    fuse-devel
    fwupd
    man-db
    systemd-container
    tuned
    tuned-ppd
    unzip
    whois
    inotify-tools

    xdg-desktop-portal-gnome
    xdg-user-dirs

    ############################
    # CAMERA / MOBILE SUPPORT  #
    ############################
    gvfs-mtp
    gvfs-smb
    ifuse
    jmtpfs
    libcamera{,-{v4l2,gstreamer,tools}}
    libimobiledevice
    uxplay

    ############################
    # GAMING / HARDWARE        #
    ############################
    steam-devices

    ############################
    # Storage UTILITIES        #
    ############################
    udiskie

    ############################
    # AUDIO SYSTEM (PIPEWIRE)  #
    ############################
    pipewire
    wireplumber

    ############################
    # DEVTOOLS / CLI UTILITIES #
    ############################
    git
    yq

    ############################
    # UBLUE-SPECIFIC PACKAGES  #
    ############################
    ublue-brew
    uupd
    ublue-os-udev-rules

    ############################
    # DISPLAY + MULTIMEDIA     #
    ############################
    @multimedia
    ffmpeg
    libavcodec
    gstreamer1-plugins-bad-free
    gstreamer1-plugins-bad-free-libs
    gstreamer1-plugins-good
    gstreamer1-plugins-base
    qt6-qtmultimedia
    lame-libs
    libjxl
    ffmpegthumbnailer
    glycin-thumbnailer
    webp-pixbuf-loader

    ############################
    # FONTS / LOCALE SUPPORT   #
    ############################
    default-fonts
    glibc-all-langpacks
    google-noto-emoji-fonts
    google-noto-color-emoji-fonts
    default-fonts-core-emoji
    nerd-fonts

    ############################
    # DESKTOP UTILITIES        #
    ############################
    bazaar
    ghostty
    nautilus
    nautilus-python
)

dnf5 -y install "${packages[@]}"

# Uninstall
packages=(
)
# dnf5 -y remove "${packages[@]}"

dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper

# Install Flathub repo
curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

echo "::endgroup::"
