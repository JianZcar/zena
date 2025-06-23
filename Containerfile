# Allow build scripts to be referenced without being copied into the final image
ARG FEDORA_VERSION=42
ARG KERNEL_VERSION=6.14.6-109.bazzite.fc42.x86_64
ARG KERNEL_FLAVOR=bazzite

# Step 2: Now FROM can use the args
FROM ghcr.io/ublue-os/akmods-nvidia-open:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods

# Step 3: Context for bind-mount scripts
FROM scratch AS ctx
COPY build_files /

# Step 4: Base image for final system
FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_VERSION} AS base

# Step 5: Copy RPMs from akmods
COPY --from=akmods /kernel-rpms /tmp/kernel-rpms
COPY --from=akmods /rpms /tmp/akmods-rpms

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

RUN dnf5 remove -y kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra --noautoremove

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    dnf5 install -y dnf5-plugins &&\
    rpm-ostree override replace /tmp/kernel-rpms/*.rpm && \
    rpm-ostree install \
      /tmp/rpms/ublue-os/ublue-os-nvidia*.rpm \
      /tmp/rpms/kmods/kmod-nvidia*.rpm && \
    dnf5 clean all
    ostree container commit
    
RUN bootc install-kernel --kver ${KERNEL_VERSION}
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
