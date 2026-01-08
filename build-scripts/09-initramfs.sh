#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

KVER=$(ls /usr/lib/modules | head -n1)
KIMAGE="/usr/lib/modules/$KVER/vmlinuz"
SIGN_DIR="/secureboot"

sbsign \
  --key "$SIGN_DIR/MOK.key" \
  --cert "$SIGN_DIR/MOK.pem" \
  --output "${KIMAGE}.signed" \
  "$KIMAGE"
mv "${KIMAGE}.signed" "$KIMAGE"

mods=(/usr/lib/modules/"$KVER"/**/*.ko)

if (( ${#mods[@]} )); then
  for mod in "${mods[@]}"; do
    /usr/src/kernels/"$KVER"/scripts/sign-file \
      sha512 "$SIGN_DIR/MOK.key" "$SIGN_DIR/MOK.pem" "$mod"
  done
else
  echo "No kernel modules to sign for $KVER"
fi

rm -f "$SIGN_DIR/MOK.key"

echo "Building initramfs for kernel version: $KVER"

if [ ! -d "/usr/lib/modules/$KVER" ]; then
  echo "Error: modules missing for kernel $KVER"
  exit 1
fi

depmod -a "$KVER"

/usr/bin/dracut \
  --no-hostonly \
  --kver "$KVER" \
  --reproducible \
  --zstd -v \
  --add ostree --add fido2 \
  -f "/usr/lib/modules/$KVER/initramfs.img"

chmod 0600 "/usr/lib/modules/$KVER/initramfs.img"

echo "::endgroup::"
