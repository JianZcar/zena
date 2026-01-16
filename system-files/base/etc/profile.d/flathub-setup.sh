#!/bin/sh

[ -z "$PS1" ] && return

MARKER="$HOME/.local/.flathub_remote_added"

if [ ! -f "$MARKER" ]; then
    flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 \
      && touch "$MARKER"
fi
