#!/bin/bash
set -ouex pipefail

echo "::group:: ===Install dnf5==="
rpm-ostree install --idempotent dnf5 dnf5-plugins
echo "::endgroup::"


echo "::group:: ===Install MoreWaita==="
git clone https://github.com/somepaulo/MoreWaita.git && cd MoreWaita
./install.sh 
cd ../ && rm -rf MoreWaita
echo "::endgroup::"


/ctx/build-scripts/base/00-image-info.sh
/ctx/build-scripts/base/01-install-kernel.sh

ostree container commit
