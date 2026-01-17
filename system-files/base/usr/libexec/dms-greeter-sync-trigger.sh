#!/bin/bash

WALLPAPER=$(dms ipc call wallpaper get 2>/dev/null)

mkdir -p "$HOME/.cache"
echo "$WALLPAPER" > "$HOME/.cache/dms-wallpaper"

systemctl start dms-greeter-sync.service
