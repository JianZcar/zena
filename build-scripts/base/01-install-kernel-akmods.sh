#!/usr/bin/bash
set -eoux pipefail

echo "::group::===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra

dnf5 -y install \
    /tmp/kernel-rpms/kernel-[0-9]*.rpm \
    /tmp/kernel-rpms/kernel-core-*.rpm \
    /tmp/kernel-rpms/kernel-modules-*.rpm \
    /tmp/kernel-rpms/kernel-uki-virt-*.rpm \
    /tmp/kernel-rpms/kernel-devel-*.rpm

dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt

dnf5 -y install \
    /tmp/akmods-rpms/kmods/*kvmfr*.rpm \
    /tmp/akmods-rpms/kmods/*xone*.rpm \
    /tmp/akmods-rpms/kmods/*openrazer*.rpm \
    /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm \
    /tmp/akmods-rpms/kmods/*wl*.rpm \
    /tmp/akmods-rpms/kmods/*framework-laptop*.rpm \
    /tmp/akmods-extra-rpms/kmods/*nct6687*.rpm \
    /tmp/akmods-extra-rpms/kmods/*gcadapter_oc*.rpm \
    /tmp/akmods-extra-rpms/kmods/*zenergy*.rpm \
    /tmp/akmods-extra-rpms/kmods/*vhba*.rpm \
    /tmp/akmods-extra-rpms/kmods/*gpd-fan*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ayaneo-platform*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ayn-platform*.rpm \
    /tmp/akmods-extra-rpms/kmods/*bmi260*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ryzen-smu*.rpm \
    /tmp/akmods-extra-rpms/kmods/*evdi*.rpm
    
for toswap in linux-firmware netronome-firmware libertas-firmware atheros-firmware realtek-firmware \
	tiwilink-firmware cirrus-audio-firmware linux-firmware-whence iwlwifi-dvm-firmware iwlwifi-mvm-firmware \ 
	amd-ucode-firmware qcom-firmware mt7xxx-firmware liquidio-firmware nxpwireless-firmware intel-vsc-firmware \
	nvidia-gpu-firmware intel-audio-firmware amd-gpu-firmware iwlegacy-firmware intel-gpu-firmware mlxsw_spectrum-firmware \
	qed-firmware mrvlprestera-firmware brcmfmac-firmware dvb-firmware; do \
	
  dnf5 -y swap --repo copr:copr.fedorainfracloud.org:bazzite-org:bazzite $toswap $toswap; \
done && unset -v toswap && \
dnf5 -y config-manager setopt "*rpmfusion*".enabled=0 && \
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons && \
dnf5 -y install scx-scheds && \
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons && \
for toswap in rpm-ostree bootc; do \
    dnf5 -y swap --repo copr:copr.fedorainfracloud.org:bazzite-org:bazzite $toswap $toswap; \
done && unset -v toswap
