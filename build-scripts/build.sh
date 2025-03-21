#!/bin/bash
set -ouex pipefail

echo "::group:: ===Install dnf5==="
rpm-ostree install --idempotent dnf5 dnf5-plugins
echo "::endgroup::"


echo "::group:: ===Install MoreWaita==="
git clone https://github.com/somepaulo/MoreWaita.git && cd MoreWaita
./install.sh 
cd ../ && rm MoreWaita
echo "::endgroup::"

# Generate image-info.json
/ctx/build-scripts/pre/install-kernel.sh

ostree container commit
