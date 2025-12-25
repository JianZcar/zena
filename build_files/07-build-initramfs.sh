#!/bin/bash
echo "::group:: ===$(basename "$0")==="
set -ouex pipefail

# Find the kernel version that was unpacked
KVER=$(ls /usr/lib/modules | head -n1)
echo "Building initramfs for kernel version: $KVER"

# Ensure the module directory exists
if [ ! -d "/usr/lib/modules/$KVER" ]; then
  echo "Error: modules missing for kernel $KVER"
  exit 1
fi

depmod -a "$KVER"

# Generate initramfs right where bootc expects it
/usr/bin/dracut \
  --no-hostonly \
  --kver "$KVER" \
  --reproducible \
  --zstd -v \
  --add ostree --add fido2 \
  -f "/usr/lib/modules/$KVER/initramfs.img"

chmod 0600 "/usr/lib/modules/$KVER/initramfs.img"

echo "::endgroup::"

