#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <extension-uuid>"
    exit 1
fi

uuid="$1"
workdir="$(mktemp -d)"
echo "Working in $workdir"
cd "$workdir"

# Detect GNOME Shell version
gnome_version=$(gnome-shell --version | awk '{print $3}')
gnome_major=$(echo "$gnome_version" | cut -d. -f1)
echo "Detected GNOME Shell version $gnome_version (major: $gnome_major)"

# Get extension metadata
echo "Fetching extension info for $uuid..."
metadata=$(curl -s "https://extensions.gnome.org/extension-info/?uuid=$uuid")

version_info=$(echo "$metadata" | jq ".shell_version_map.\"$gnome_major\"")

if [[ "$version_info" == "null" ]]; then
    echo "No compatible version found for GNOME Shell $gnome_version"
    exit 1
fi

version_tag=$(echo "$version_info" | jq -r '.version')
pk=$(echo "$version_info" | jq -r '.pk')

echo "Using version_tag: $version_tag, pk: $pk"

# Encode @ as %40 for the API call
encoded_uuid="${uuid//@/%40}"

zipfile="${uuid}.zip"
api_url="https://extensions.gnome.org/api/v1/extensions/${encoded_uuid}/versions/${version_tag}/?format=zip"

echo "Downloading from API: $api_url"
curl -s -L \
     -H "accept: application/zip" \
     -o "$zipfile" \
     "$api_url"

# Install system-wide
extdir="/usr/share/gnome-shell/extensions/$uuid"
echo "Installing to $extdir"
mkdir -p "$extdir"
unzip -q "$zipfile" -d "$extdir"

# Check for metadata
if [ ! -f "$extdir/metadata.json" ]; then
    echo "metadata.json is missing. The install may be incomplete."
    exit 1
fi

# Compile GSettings schema if present
if [ -d "$extdir/schemas" ]; then
    echo "Compiling GSettings schema..."
    glib-compile-schemas "$extdir/schemas"
fi

# Fix permissions
echo "Fixing permissions..."
chmod -R a+r "$extdir"
find "$extdir" -type d -exec chmod 755 {} \;
find "$extdir" -type f -exec chmod 644 {} \;

echo "Extension $uuid installed system-wide for GNOME Shell $gnome_version."

# Clean up
rm -rf "$workdir"
