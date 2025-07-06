# Zena

## Overview

**Zena** is a customized [Ublue OS](https://github.com/ublue-os) image based on the [bootc](https://github.com/bootc-dev/bootc) container image framework. This project is designed for my personal use, providing a tailored Fedora-based OS with advanced gaming, multimedia, and virtualization features.

- **Base Framework:** [bootc](https://github.com/bootc-dev/bootc) (container-based OS images)
- **Template Origin:** [ublue-os/image-template](https://github.com/ublue-os/image-template)
- **License:** [Apache License 2.0](LICENSE)

## Features

- **Bazzite Kernel:** Enhanced for gaming and performance.
- **Custom Package Set:** Adds gaming, multimedia, hardware, and virtualization packages.
- **Flathub:** Uses Flathub as the main repo for flatpaks instead of fedora
- **Wayland & GNOME Enhancements:** Includes custom GNOME Shell extensions, Wayland utilities, and display management tools.
- **Gaming Support:** Steam, LatencyFleX, Looking Glass, and additional tools for optimal Linux gaming.
- **Virtualization Ready:** QEMU, libvirt, OVMF, and QCOW2/RAW/ISO image building.
- **Networking:** Tailscale and other networking enhancements.
- **Multimedia:** Advanced audio (Pipewire, LADSPA plugins), video, and hardware support.

## Used GNOME Shell Extensions

This image comes bundled with several GNOME Shell extensions, some of which are patched or custom-developed:

### Patched & Custom Extensions
- **light-shell-plus@jianzcar.github**    
  [Source](https://github.com/JianZcar/light-shell-plus)
- **peek-top-bar-on-fullscreen@marcinjahn.com**  
  _Patched_  
  [Source](https://github.com/JianZcar/peek-top-bar-on-fullscreen)

### Additional Extensions
Installed via script (patched for compatibility if needed):
- **ideapad@laurento.frittella**
- **accent-directories@taiwbi.com**
- **wireless-hid@chlumskyvaclav.gmail.com**
- **gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com**
- **window-centering@hnjjhmtr27**
- **splashindicator@ochi12.github.com**
- **disable-workspace-switcher-overlay@cleardevice**

Packaged (Fedora/RPMFusion):
- **gnome-shell-extension-appindicator**
- **gnome-shell-extension-blur-my-shell**
- **gnome-shell-extension-burn-my-windows**
- **gnome-shell-extension-caffeine**
- **gnome-shell-extension-compiz-windows-effect**
- **gnome-shell-extension-hotedge**
- **gnome-shell-extension-just-perfection**
- **gnome-shell-extension-restart-to**
- **gnome-shell-extension-user-theme**
- **gnome-shell-extension-supergfxctl-gex** (for NVIDIA/supergfxctl integration)

> ⚠️ **This image is for my personal use and not intended for general public use. Use at your own risk!**
(Unless if many want me to support it for public use, just make a pull request)

## Acknowledgements

- [ublue-os/image-template](https://github.com/ublue-os/image-template)
- [bootc-dev/bootc](https://github.com/bootc-dev/bootc)
- [Bazzite](https://github.com/bazzite-org/bazzite)
- All upstream Fedora, RPMFusion, and COPR maintainers.

## License

This project is licensed under the [Apache License 2.0](LICENSE).

---
*Maintained by [JianZcar](https://github.com/JianZcar)*
