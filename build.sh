#!/bin/bash

set -ouex pipefail

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

# Fetch the package list from the "Fedora Workstation" group
PACKAGE_LIST=$(dnf group info "Fedora Workstation" | awk '/Mandatory Packages:/,/Optional Packages:/' | grep -vE 'Mandatory Packages:|Optional Packages:' | tr -d '* ')

# Convert the list into a space-separated string
PACKAGES=$(echo $PACKAGE_LIST | tr '\n' ' ')

if [[ -z "$PACKAGES" ]]; then
    echo "No packages found in @fedora-workstation group."
    exit 1
fi

# Install the extracted packages using rpm-ostree
echo "Installing packages: $PACKAGES"
rpm-ostree install $PACKAGES

# Commit the changes
ostree container commit
