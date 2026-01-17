#!/bin/bash

set -e

ACTIVE_USER=""
for sid in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
    TYPE=$(loginctl show-session $sid -p Type --value)
    STATE=$(loginctl show-session $sid -p State --value)

    if [ "$TYPE" = "wayland" ] && [ "$STATE" = "active" ]; then
        ACTIVE_USER=$(loginctl show-session $sid -p Name --value)
        break
    fi
done

if [ -z "$ACTIVE_USER" ]; then
    echo "No active Wayland session found; not syncing greeter."
    exit 0
fi

GREETER_CACHE="/var/cache/dms-greeter"
mkdir -p "$GREETER_CACHE"

cp "/home/$ACTIVE_USER/.config/DankMaterialShell/settings.json" "$GREETER_CACHE/settings.json"
cp "/home/$ACTIVE_USER/.local/state/DankMaterialShell/session.json" "$GREETER_CACHE/session.json"
cp "/home/$ACTIVE_USER/.cache/DankMaterialShell/dms-colors.json" "$GREETER_CACHE/colors.json"

WP_PATH_FILE="/home/$ACTIVE_USER/.cache/DankMaterialShell/wallpaper"
if [ -f "$WP_PATH_FILE" ]; then
    WP=$(cat "$WP_PATH_FILE")
    if [ -n "$WP" ] && [ -f "$WP" ]; then
        cp "$WP" "$GREETER_CACHE/wallpaper.png"
    fi
fi

sed -i 's|"wallpaperPath": *"[^"]*"|"wallpaperPath": "'"$GREETER_CACHE"/wallpaper.png'"|' "$GREETER_CACHE/session.json"

chown -R greeter:greeter "$GREETER_CACHE"
chmod -R a+r "$GREETER_CACHE"
