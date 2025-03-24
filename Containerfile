ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="41"
ARG SOURCE_IMAGE="${BASE_IMAGE_NAME}-main"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"

ARG KERNEL_FLAVOR="bazzite"
ARG KERNEL_VERSION="6.13.6-103.bazzite.fc41.x86_64"

FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods-extra
FROM ghcr.io/ublue-os/akmods-nvidia:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS nvidia-akmods

FROM scratch AS ctx
COPY build-scripts /

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS base

ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="41"
ARG KERNEL_FLAVOR="bazzite"
ARG IMAGE_NAME="zena"
ARG IMAGE_VENDOR="JianZcar"
ARG IMAGE_TAG="stable"
ARG VERSION=""

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
     --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=akmods-extra,src=/rpms,dst=/tmp/akmods-extra-rpms \
    --mount=type=bind,from=nvidia-akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    find /tmp/rpms
    /ctx/build.sh
