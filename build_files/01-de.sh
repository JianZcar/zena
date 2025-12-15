#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  chaotic-aur/niri-git
  xwayland-satellite

  chaotic-aur/dms-shell-git
  chaotic-aur/matugen-git

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
)

pacman -Sy --noconfirm --needed base-devel paru rust
useradd -m -s /bin/bash build
usermod -L build

echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-build-aur
chmod 0440 /etc/sudoers.d/99-build-aur

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
rm -f /etc/sudoers.d/99-build-aur
userdel -r build
pacman -Rns --noconfirm base-devel paru rust

pacman -S --noconfirm "${packages[@]}"

cat > /etc/nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json << 'EOF'
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

cat > /etc/greetd/niri.kdl << 'EOF'
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

mkdir -p /etc/greetd
cat > /etc/greetd/config.toml << 'EOF'
[general]
service = "greetd-spawn"

[terminal]
vt = 1

[default_session]
command = "dms-greeter --command niri -C /etc/greetd/niri.kdl"
user = "greeter"
EOF

cat > /etc/greetd/greetd-spawn.pam_env.conf << 'EOF'
XDG_SESSION_TYPE DEFAULT=wayland OVERRIDE=wayland
EOF

cat > /etc/pam.d/greetd-spawn << 'EOF'
auth       include      greetd
auth       required     pam_env.so conffile=/etc/greetd/greetd-spawn.pam_env.conf
account    include      greetd
session    include      greetd
EOF

system_services=(
    greetd
)
systemctl enable "${system_services[@]}"

user_services=(
    dms
    dsearch
    gnome-keyring-daemon.socket
    gnome-keyring-daemon.service
)
systemctl --global enable "${user_services[@]}"

echo "::endgroup::"
