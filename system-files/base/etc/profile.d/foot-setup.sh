#!/bin/sh

FOOT_DIR="$HOME/.config/foot"
FOOT_CONFIG="$FOOT_DIR"/foot.ini
DMS_CONFIG="$FOOT_DIR"/dank-colors.ini
if [ -f "$FOOT_CONFIG" ]; then
    sed -i "s|<USERNAME>|$USER|g" "$FOOT_CONFIG"
fi
if [ ! -e "$DMS_CONFIG" ]; then
    touch "$DMS_CONFIG"
fi
