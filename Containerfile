ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="41"
ARG SOURCE_IMAGE="${BASE_IMAGE_NAME}-main"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"

ARG KERNEL_FLAVOR="bazzite"
ARG KERNEL_VERSION="6.13.7-108.bazzite.fc41.x86_64"

FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods-extra
FROM ghcr.io/ublue-os/akmods-nvidia:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS nvidia-akmods

FROM scratch AS ctx
COPY build-scripts /

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS base

ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="41"
ARG IMAGE_NAME="zena"
ARG IMAGE_VENDOR="JianZcar"
ARG IMAGE_TAG="stable"
ARG VERSION=""

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install dnf5-plugins && \
    dnf5 -y downgrade dnf5 && \
    for copr in \
        bazzite-org/bazzite \
        bazzite-org/bazzite-multilib \
        ublue-os/staging \
        ublue-os/packages \
        bazzite-org/LatencyFleX \
        bazzite-org/obs-vkcapture \
        bazzite-org/wallpaper-engine-kde-plugin \
        ycollet/audinux \
        bazzite-org/rom-properties \
        bazzite-org/webapp-manager \
        bazzite-org/vk_hdr_layer \
        hhd-dev/hhd \
        che/nerd-fonts \
        hikariknight/looking-glass-kvmfr \
        mavit/discover-overlay \
        lizardbyte/beta \
        rok/cdemu \
        rodoma92/kde-cdemu-manager \
        rodoma92/rmlint \
        ilyaz/LACT \
        tulilirockz/fw-fanctrl; \
    do \
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
    dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*"

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=akmods-extra,src=/rpms,dst=/tmp/akmods-extra-rpms \
    --mount=type=bind,from=nvidia-akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
