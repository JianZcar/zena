ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="41"
ARG SOURCE_IMAGE="${BASE_IMAGE_NAME}-main"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"

ARG KERNEL_FLAVOR="bazzite"
ARG KERNEL_VERSION="6.13.6-103.bazzite.fc41.x86_64"

FROM scratch AS ctx
COPY build-scripts /

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS base

ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="41"
ARG KERNEL_FLAVOR="bazzite"
ARG KERNEL_VERSION="6.13.6-103.bazzite.fc41.x86_64"
ARG IMAGE_NAME="zena"
ARG IMAGE_VENDOR="JianZcar"
ARG IMAGE_TAG="stable"
ARG VERSION=""

COPY --from=ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} /rpms/ /tmp/rpms
COPY --from=ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} /kernel-rpms/ /tmp/kernel-rpms
COPY --from=ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} /rpms/ /tmp/rpms
COPY --from=ghcr.io/ublue-os/akmods-nvidia:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} /rpms/ /tmp/rpms
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build.sh
