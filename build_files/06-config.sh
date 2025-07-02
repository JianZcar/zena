echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

CONFIG_FILE="/ctx/config.yaml"
OUTDIR="/etc"
SCHEMA_DIR="/usr/share/glib-2.0/schemas"

mkdir -p "$OUTDIR" "$SCHEMA_DIR"

echo "📄 Using config file from: $CONFIG_FILE"
echo "📁 Will write GSchema overrides to: $SCHEMA_DIR"

index=0
while yq -e ".[$index]" "$CONFIG_FILE" >/dev/null 2>&1; do
  echo "🔍 Entry $index:"
  yq ".[$index]" "$CONFIG_FILE"

  if yq -e ".[$index] | has(\"gschema\")" "$CONFIG_FILE" >/dev/null 2>&1; then
    echo "✅ Found .gschema in entry $index"

    id=$(yq -r ".[$index].gschema.id" "$CONFIG_FILE")
    file=$(yq -r ".[$index].gschema.filename" "$CONFIG_FILE")
    settings_path="$SCHEMA_DIR/$file"

    echo "📝 Writing schema override to: $settings_path"
    echo "[$id]" > "$settings_path"

    setting_keys=$(yq -r ".[$index].gschema.settings | keys | .[]" "$CONFIG_FILE")
    for key in $setting_keys; do
      value=$(yq -r ".[$index].gschema.settings[\"$key\"]" "$CONFIG_FILE")

      # Format array values properly
      if [[ "$value" == \[*\] ]]; then
        echo "$key=$value" >> "$settings_path"
      else
        escaped=$(printf '%s' "$value" | sed "s/'/''/g")
        echo "$key='$escaped'" >> "$settings_path"
      fi
    done

    echo "✅ Created GSchema override: $settings_path"
  else
    path=$(yq -r ".[$index].path" "$CONFIG_FILE")
    content=$(yq -r ".[$index].content" "$CONFIG_FILE")
    fullpath="$OUTDIR/$path"
    mkdir -p "$(dirname "$fullpath")"
    echo "$content" > "$fullpath"
    echo "📄 Wrote plain file to: $fullpath"
  fi

  index=$((index + 1))
done

echo "⚙️ Compiling schemas in: $SCHEMA_DIR"
glib-compile-schemas "$SCHEMA_DIR"
echo "✅ Successfully compiled schemas in $SCHEMA_DIR"

echo "::endgroup::"
