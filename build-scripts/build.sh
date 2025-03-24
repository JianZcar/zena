#!/usr/bin/bash
set -ouex pipefail

echo "::group:: ===Install dnf5==="
rpm-ostree install --idempotent dnf5 dnf5-plugins
echo "::endgroup::"

/ctx/base/00-image-info.sh
/ctx/base/01-setup-copr-repos.sh
/ctx/base/02-install-kernel-akmods.sh
/ctx/base/02-install-nvidia.sh


echo "::group:: ===Install MoreWaita==="
git clone https://github.com/somepaulo/MoreWaita.git && cd MoreWaita
./install.sh 
cd ../ && rm -rf MoreWaita
echo "::endgroup::"

/ctx/build-initramfs.sh
/ctx/cleanup.sh
