#!/bin/bash

run_scripts() {
  dir="/ctx/build-scripts/$1"
  if [ -d "$dir" ]; then
    for script in "$dir"/*; do
      [ -x "$script" ] && "$script"
    done
  else
  		echo "Directory $dir does not exist"
  fi
}

set -ouex pipefail

find /tmp/build-scripts -type f -exec chmod +x {} \;

run_scripts "pre"

git clone https://github.com/somepaulo/MoreWaita.git && cd MoreWaita
./install.sh && rm MoreWaita || echo "MoreWaita installation failed!"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket

# Commit the changes
ostree container commit
