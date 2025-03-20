FROM ghcr.io/ublue-os/silverblue-main:41

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

#Install DNF 5
RUN rpm-ostree install --idempotent dnf5 dnf5-plugins

# Add the Cachy kernel COPR repository file
RUN cd /etc/yum.repos.d/ && \
    wget --no-hsts https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo

# Override the default kernel and install the Cachy kernel
RUN dnf5 install -y kernel-devel kernel-headers && \
    rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra \
      --install kernel-cachyos && \
    setsebool -P domain_kernel_load_modules on && \
    dracut -f && \
    sync && \
    ostree container commit

COPY build.sh /tmp/build.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
    
