#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

cat << 'EOF' > /etc/profile.d/brew.sh
[[ -d /home/linuxbrew/linuxbrew && $- == *i* ]] && \
eval "$(/home/linuxbrew/linuxbrew/bin/brew shellenv)"
EOF

cat << 'EOF' > /usr/lib/systemd/system/brew-setup.service
[Unit]
Description=Setup Homebrew from tarball
After=local-fs.target
ConditionPathExists=!/home/linuxbrew/.linuxbrew
ConditionPathExists=/usr/share/homebrew.tar.zst

[Service]
Type=oneshot
Environment=NONINTERACTIVE=1
ExecStart=/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ExecStart=/usr/bin/chown -R 1000:1000 /home/linuxbrew/.linuxbrew

[Install]
WantedBy=multi-user.target
EOF


echo "::endgroup::"
