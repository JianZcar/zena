#!/bin/bash

set -ouex pipefail

CONFIG_FILE="/ctx/config.yaml"
SCHEMA_DIR="/usr/share/glib-2.0/schemas"

mkdir -p "/etc" "/etc/xdg/autostart" "$SCHEMA_DIR"

echo "Using config file from: $CONFIG_FILE"
echo "Will write GSchema overrides to: $SCHEMA_DIR"

echo "Dumping contents of $CONFIG_FILE:"
cat "$CONFIG_FILE"
echo

index=0
while yq -e ".[$index]" "$CONFIG_FILE" >/dev/null 2>&1; do
  echo "Processing entry $index:"
  yq ".[$index]" "$CONFIG_FILE"

  if [[ $(yq ".[$index] | has(\"gschema\")" "$CONFIG_FILE") == "true" ]]; then
    echo "Found .gschema in entry $index"

    id=$(yq -r ".[$index].gschema.id" "$CONFIG_FILE")
    file=$(yq -r ".[$index].gschema.filename" "$CONFIG_FILE")
    settings_path="$SCHEMA_DIR/$file"

    echo "Writing schema override to: $settings_path"
    echo "[$id]" > "$settings_path"

    setting_keys=$(yq -r ".[$index].gschema.settings | keys | .[]" "$CONFIG_FILE")
    for key in $setting_keys; do
      tag=$(yq -r ".[$index].gschema.settings[\"$key\"] | tag" "$CONFIG_FILE")

      if [[ "$tag" == "!!seq" ]]; then
        # Read array values into Bash array
        mapfile -t array <<< "$(yq -r ".[$index].gschema.settings[\"$key\"][]" "$CONFIG_FILE")"

        # Escape and quote each item
        quoted_items=()
        for item in "${array[@]}"; do
          quoted_items+=("'${item//\'/\'\'}'")
        done

        # Join items with commas and write
        IFS=','; echo "$key=[${quoted_items[*]}]" >> "$settings_path"; unset IFS
      elif [[ "$tag" == "!!bool" || "$tag" == "!!int" || "$tag" == "!!float" ]]; then
        # Write booleans and numbers unquoted
        value=$(yq -r ".[$index].gschema.settings[\"$key\"]" "$CONFIG_FILE")
        echo "$key=$value" >> "$settings_path"
      else
        # Quote and escape string
        value=$(yq -r ".[$index].gschema.settings[\"$key\"]" "$CONFIG_FILE")
        escaped=$(printf '%s' "$value" | sed "s/'/''/g")
        echo "$key='$escaped'" >> "$settings_path"
      fi
    done

    echo "Created GSchema override: $settings_path"
  else
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
  fi

  index=$((index + 1))
done

echo "Compiling schemas in: $SCHEMA_DIR"
glib-compile-schemas "$SCHEMA_DIR"
echo "Successfully compiled schemas in $SCHEMA_DIR"
dconf update
