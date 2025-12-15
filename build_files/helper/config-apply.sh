#!/bin/bash

set -ouex pipefail

CONFIG_FILE="/ctx/config.yaml"

echo "Using config file from: $CONFIG_FILE"

echo "Dumping contents of $CONFIG_FILE:"
cat "$CONFIG_FILE"
echo

index=0
while yq -e ".[$index]" "$CONFIG_FILE" >/dev/null 2>&1; do
  echo "Processing entry $index:"
  yq ".[$index]" "$CONFIG_FILE"

  path=$(yq -r ".[$index].path" "$CONFIG_FILE")
  content=$(yq -r ".[$index].content" "$CONFIG_FILE")
  fullpath="$path"
  mkdir -p "$(dirname "$path")"
  echo "$content" > "$path"
  echo "Wrote plain file to: $path"
  if yq -e ".[$index] | has(\"permissions\")" "$CONFIG_FILE" >/dev/null; then
    perms=$(yq -r ".[$index].permissions" "$CONFIG_FILE")
    chmod "$perms" "$path"
    echo "Set permissions $perms on $path"
  fi

  index=$((index + 1))
done
