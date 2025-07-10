#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

cp --no-dereference --preserve=links /usr/lib/libdrm.so.2 /usr/lib/libdrm.so
cp --no-dereference --preserve=links /usr/lib64/libdrm.so.2 /usr/lib64/libdrm.so

sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvim.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yad-icon-browser.desktop

ln -s /usr/lib/opentabletdriver/OpenTabletDriver.Daemon /usr/local/bin/OpenTabletDriver.Daemon
ln -s /usr/lib/opentabletdriver/OpenTabletDriver.UX.Gtk /usr/local/bin/OpenTabletDriver.UX.Gtk
ln -s /usr/lib/opentabletdriver/OpenTabletDriver.Console /usr/local/bin/OpenTabletDriver.Console

echo "::endgroup::"
