#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs

pkgs=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
    kernel-modules-akmods
    kernel-devel
    kernel-devel-matched
    kernel-tools
    kernel-tools-libs
    kernel-common
    kernel-nvidia
)

PKG_PAT=()
for pkg in "${pkgs[@]}"; do
    # FIXME: assumes the kernel starts with version 6
    PKG_PAT+=("/rpms/kernel/${pkg}-6"*)
done

dnf5 -y install ${PKG_PAT[@]} --no-allow-downgrade

dnf5 versionlock add $pkgs

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

dnf5 -y config-manager setopt "*rpmfusion*".enabled=false
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
dnf5 -y install scx-scheds
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

echo "::endgroup::"
