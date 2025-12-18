#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

# Make a build user for AUR
useradd -m -s /bin/bash build
usermod -L build

echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-build-aur
chmod 0440 /etc/sudoers.d/99-build-aur

cat << 'EOF' > /etc/sudoers.d/00-sudo-config
%wheel ALL=(ALL:ALL) ALL

Defaults pwfeedback
Defaults secure_path="/usr/local/bin:/usr/bin:/bin:/home/linuxbrew/.linuxbrew/bin"
Defaults env_keep += "EDITOR VISUAL PATH"
Defaults timestamp_timeout=0
EOF
chmod 440 /etc/sudoers.d/00-sudo-config

cat << 'EOF' > /etc/profile.d/brew.sh
[[ -d /home/linuxbrew/linuxbrew && $- == *i* ]] && \
eval "$(/home/linuxbrew/linuxbrew/bin/brew shellenv)"
EOF

cat << 'EOF' > /usr/libexec/group-fix
#!/bin/sh

cat /usr/lib/sysusers.d/*.conf \
  | grep -e "^g" \
  | grep -v -e "^#" \
  | awk "NF" \
  | awk '{print $2}' \
  | grep -v -e "wheel" -e "root" -e "sudo" \
  | xargs -I{} sed -i "/{}/d" "$1"
EOF
chmod +x /usr/libexec/group-fix

cat << 'EOF' > /usr/lib/systemd/system/group-fix.service
[Unit]
Description=Fix system groups
Wants=local-fs.target
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/libexec/group-fix /etc/group
ExecStart=/usr/libexec/group-fix /etc/gshadow
ExecStart=systemd-sysusers

[Install]
WantedBy=default.target multi-user.target
EOF

cat <<'EOF' > /usr/lib/systemd/system-preset/01-group-fix.preset
enable group-fix.service
EOF

cat << 'EOF' > /usr/lib/systemd/system/update-bootc-remote.service
[Unit]
Description=Bootc switch to remote Zena image
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bootc switch --mutate-in-place --transport registry ghcr.io/jianzcar/zena:stable

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /usr/lib/systemd/system-preset/01-update-bootc-remote.preset
enable update-bootc-remote.service
EOF

cat << 'EOF' > /usr/libexec/initial-install
#!/bin/bash

mkdir -p /var/cache/dms-greeter
systemctl set-default graphical.target
touch /var/init
( sleep 2 && systemctl reboot ) &
exit 0
EOF
chmod +x /usr/libexec/initial-install

cat << 'EOF' > /usr/lib/systemd/system/initial-install.service
[Unit]
Description=Initial-Installation fixes
Wants=local-fs.target
After=local-fs.target
ConditionPathExists=!/var/init

[Service]
Type=oneshot
ExecStart=/usr/libexec/initial-install

[Install]
WantedBy=default.target multi-user.target
EOF

cat << 'EOF' > /usr/lib/systemd/system-preset/01-initial-install.preset
enable initial-install.service
EOF

echo "::endgroup::"
