#!/bin/sh
FOOT_CONFIG="$HOME/.config/foot/foot.ini"

if [ -f "$FOOT_CONFIG" ]; then
    sed -i "s|<USERNAME>|$USER|g" "$FOOT_CONFIG"
fi
