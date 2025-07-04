#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

cp --no-dereference --preserve=links /usr/lib/libdrm.so.2 /usr/lib/libdrm.so
cp --no-dereference --preserve=links /usr/lib64/libdrm.so.2 /usr/lib64/libdrm.so

sed -i 's|^Exec=lutris %U$|Exec=env PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python lutris %U|' /usr/share/applications/net.lutris.Lutris.desktop

sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvim.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yad-icon-browser.desktop

# Use colored icon for tray icon of steam for better visibility in light mode
cp -f /usr/share/pixmaps/steam.png /usr/share/pixmaps/steam_tray_mono.png

echo "::endgroup::"
