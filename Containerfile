ARG FEDORA_VERSION=42
ARG KERNEL_VERSION=6.14.6-109.bazzite.fc42.x86_64
ARG KERNEL_FLAVOR=bazzite
ARG BASE_IMAGE_NAME=silverblue

FROM ghcr.io/ublue-os/akmods-nvidia-open:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods

FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/${BASE_IMAGE_NAME}-main:${FEDORA_VERSION} AS base

COPY --from=akmods / /tmp/akmods-nvidia
RUN find /tmp/akmods-nvidia

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

# Forced

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    mkdir -p /var/roothome && \
    dnf5 -y install dnf5-plugins && \
    for copr in \
        bazzite-org/bazzite \
        bazzite-org/bazzite-multilib \
        ublue-os/staging \
        ublue-os/packages \
        bazzite-org/LatencyFleX \
        bazzite-org/obs-vkcapture \
        ycollet/audinux \
        bazzite-org/rom-properties \
        bazzite-org/webapp-manager \
        hhd-dev/hhd \
        che/nerd-fonts \
        hikariknight/looking-glass-kvmfr \
        mavit/discover-overlay \
        rok/cdemu \
        lizardbyte/beta; \
    do \
        echo "Enabling copr: $copr"; \
        dnf5 -y copr enable $copr; \
        dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:${copr////:}.priority=98 ;\
    done && unset -v copr && \
    dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} && \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 -y install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo && \
    dnf5 -y config-manager setopt "*bazzite*".priority=1 && \
    dnf5 -y config-manager setopt "*akmods*".priority=2 && \
    dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade" && \
    dnf5 -y config-manager setopt "terra-mesa".enabled=true && \
    dnf5 -y config-manager setopt "terra-nvidia".enabled=false && \
    eval "$(/ctx/dnf5-setopt setopt '*negativo17*' priority=4 exclude='mesa-* *xone*')" && \
    dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*" && \
    dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" && \
    dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*" && \
    dnf5 clean all && \
    rm -rf /tmp/* || true && \
    ostree container commit

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
    /ctx/build.sh && \
    dnf5 config-manager setopt "terra-mesa".enabled=1 && \
    dnf5 -y copr enable ublue-os/staging && \
    dnf5 -y install \
        mesa-vdpau-drivers.x86_64 \
        mesa-vdpau-drivers.i686 && \
    curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/main/refs/heads/main/build_files/nvidia-install.sh && \
    chmod +x /tmp/nvidia-install.sh && \
    IMAGE_NAME="${BASE_IMAGE_NAME}" /tmp/nvidia-install.sh && \
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
    ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so && \
    dnf5 config-manager setopt "terra-mesa".enabled=0 && \
    dnf5 -y copr disable ublue-os/staging && \
    dnf5 clean all && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
