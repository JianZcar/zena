#!/usr/bin/bash
set -ouex pipefail

echo "::group:: ===Install dnf5==="
rpm-ostree install --idempotent dnf5 dnf5-plugins
echo "::endgroup::"

/ctx/base/00-image-info.sh
/ctx/base/01-install-kernel-akmods.sh


echo "::group:: ===Install MoreWaita==="
git clone https://github.com/somepaulo/MoreWaita.git && cd MoreWaita
./install.sh 
cd ../ && rm -rf MoreWaita
echo "::endgroup::"

ostree container commit
