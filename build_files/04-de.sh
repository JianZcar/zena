#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

mkdir -p /etc/skel/.config/niri
cp -a /ctx/niri/. /etc/skel/.config/niri/
cp -a /ctx/ghostty/. /etc/skel/.config/ghostty/

packages=(
  niri
  xwayland-satellite

  dms-shell-git
  matugen-git

  greetd

  gnome-keyring

  i2c-tools
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-gnome
  xdg-user-dirs
  xdg-utils
  wlsunset

  glycin
  evince
  ffmpegthumbnailer
  gnome-epub-thumbnailer
  libgsf

  wl-clipboard
  cliphist
  cava

  ghostty
  nautilus
  nautilus-python
  bazaar
)

AUR_PKGS=(
  quickshell-git
  dsearch-git
  greetd-dms-greeter-git
  raw-thumbnailer
)
AUR_PKGS_STR="${AUR_PKGS[*]}"

su - build -c "
set -xeuo pipefail
paru -S --noconfirm --needed $AUR_PKGS_STR
"
pacman -S --noconfirm "${packages[@]}"

cat << 'EOF' > /etc/nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json
{
    "rules": [
        {
            "pattern": {
                "feature": "procname",
                "matches": "niri"
            },
            "profile": "Limit Free Buffer Pool On Wayland Compositors"
        }
    ],
    "profiles": [
        {
            "name": "Limit Free Buffer Pool On Wayland Compositors",
            "settings": [
                {
                    "key": "GLVidHeapReuseRatio",
                    "value": 0
                }
            ]
        }
    ]
}
EOF

cat << 'EOF' > /etc/greetd/niri.kdl
input {
    keyboard {
        numlock
    }

    touchpad {
        tap
        drag-lock
        natural-scroll
        scroll-method "edge"
    }
}

hotkey-overlay {
    skip-at-startup
}

environment {
    DMS_RUN_GREETER "1"
}

gestures {
  hot-corners {
    off
  }
}

layout {
  background-color "#000000"
}
EOF

cat << 'EOF' > /etc/greetd/config.toml
[terminal]
vt = 1

[default_session]
command = "dms-greeter --command niri -C /etc/greetd/niri.kdl"
user = "greeter"
EOF

system_services=(
  greetd
)
systemctl enable "${system_services[@]}"

user_services=(
  niri
  dms
  dsearch
  gnome-keyring-daemon.socket
  gnome-keyring-daemon.service
)
systemctl --global enable "${user_services[@]}"

echo "::endgroup::"
