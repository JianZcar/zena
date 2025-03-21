FROM scratch AS ctx
COPY / /

FROM ghcr.io/ublue-os/silverblue-main:41

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build-scripts/build.sh
