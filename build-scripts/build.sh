#!/bin/bash



set -ouex pipefail


git clone https://github.com/somepaulo/MoreWaita.git && cd MoreWaita
./install.sh && rm MoreWaita || echo "MoreWaita installation failed!"

# Generate image-info.json
/ctx/build-scripts/pre/install-kernel.sh

ostree container commit
