#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

/ctx/helper/config-apply.sh

mkdir -p /etc/xdg/autostart
mkdir -p /etc/zena
cp -r /ctx/first-boot /etc/zena/

sed -i 's/#UserspaceHID.*/UserspaceHID=true/' /etc/bluetooth/input.conf
sed -i 's/^#SCX_FLAGS=/SCX_FLAGS=/' /etc/default/scx

sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher
sed -i 's|grub_probe} --target=device /`|grub_probe} --target=device /sysroot`|g' /usr/bin/grub2-mkconfig

# Patch rtkit
sed -i 's|^ExecStart=.*|ExecStart=/usr/libexec/rtkit-daemon --no-canary|' /usr/lib/systemd/system/rtkit-daemon.service

sed -i 's/balanced=balanced$/balanced=balanced-bazzite/' /etc/tuned/ppd.conf
sed -i 's/performance=throughput-performance$/performance=throughput-performance-bazzite/' /etc/tuned/ppd.conf
sed -i 's/balanced=balanced-battery$/balanced=balanced-battery-bazzite/' /etc/tuned/ppd.conf

ln -s /usr/bin/true /usr/bin/pulseaudio

cp --no-dereference --preserve=links /usr/lib/libdrm.so.2 /usr/lib/libdrm.so
cp --no-dereference --preserve=links /usr/lib64/libdrm.so.2 /usr/lib64/libdrm.so

sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop

echo "GSK_RENDERER=ngl" >/usr/lib/environment.d/nvidia-gsk.conf

echo "::endgroup::"
