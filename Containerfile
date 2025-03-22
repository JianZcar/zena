ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="41"
ARG SOURCE_IMAGE="${BASE_IMAGE_NAME}-main"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"

FROM scratch AS ctx
COPY / /

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS base

ARG BASE_IMAGE_NAME="silverblue"
ARG IMAGE_NAME="zena"
ARG IMAGE_VENDOR="JianZcar"
ARG IMAGE_TAG="stable"
ARG VERSION=""

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build-scripts/build.sh
