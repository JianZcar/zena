# Zena

## Overview

**Zena** is a customized Fedora image based on the [bootc](https://github.com/bootc-dev/bootc) container image framework. This project is designed for my personal use, providing a tailored Fedora-based OS with advanced gaming, multimedia, and virtualization features.

- **Base Framework:** [bootc](https://github.com/bootc-dev/bootc) (container-based OS images)
- **Template Origin:** [ublue-os/image-template](https://github.com/ublue-os/image-template)
- **License:** [Apache License 2.0](LICENSE)

## Features

- **Bazzite Kernel:** Enhanced for gaming and performance.
- **Custom Package Set:** Adds gaming, multimedia, hardware, and virtualization packages.
- **Flathub:** Uses Flathub as the main repo for flatpaks instead of fedora
- **Wayland & GNOME Enhancements:** Includes custom GNOME Shell extensions, Wayland utilities, and display management tools.
- **Gaming Support:** Steam, LatencyFleX, Looking Glass, and additional tools for optimal Linux gaming.
- **Networking:** Tailscale and other networking enhancements.
- **Multimedia:** Advanced audio (Pipewire, LADSPA plugins), video, and hardware support.

## Used GNOME Shell Extensions

This image comes bundled with several GNOME Shell extensions, some of which are patched or custom-developed:

- [**light shell plus**](https://github.com/JianZcar/light-shell-plus)
- [**peek top bar**](https://github.com/JianZcar/peek-top-bar)
- [**ideapad**](https://extensions.gnome.org/extension/2992/ideapad/)
- [**accent directories**](https://extensions.gnome.org/extension/7535/accent-directories/)
- [**wireless hid**](https://extensions.gnome.org/extension/4228/wireless-hid/)
- [**gnome fuzzy app search**](https://extensions.gnome.org/extension/3956/gnome-fuzzy-app-search/)
- [**window centering**](https://extensions.gnome.org/extension/8087/window-centering/)
- [**splash indicator**](https://extensions.gnome.org/extension/8187/splash-indicator/)
- [**disable workspace switcher overlay**](https://extensions.gnome.org/extension/6358/disable-workspace-switcher-overlay/)
- [**app indicator**](https://extensions.gnome.org/extension/615/appindicator-support/)
- [**blur my shell**](https://extensions.gnome.org/extension/3193/blur-my-shell/)
- [**burn my windows**](https://extensions.gnome.org/extension/4679/burn-my-windows/)
- [**caffeine**](https://extensions.gnome.org/extension/517/caffeine/)
- [**hotedge**](https://extensions.gnome.org/extension/4222/hot-edge/)
- [**just perfection**](https://extensions.gnome.org/extension/3843/just-perfection/)
- [**restart to**](https://extensions.gnome.org/extension/7215/restart-to/)

> ⚠️ **This image is for my personal use and not intended for general public use. Use at your own risk!**

## Acknowledgements

- [ublue-os/image-template](https://github.com/ublue-os/image-template)
- [bootc-dev/bootc](https://github.com/bootc-dev/bootc)
- [Bazzite](https://github.com/bazzite-org/bazzite)
- All upstream Fedora, RPMFusion, and COPR maintainers.

## License

This project is licensed under the [Apache License 2.0](LICENSE).

---
*Maintained by [JianZcar](https://github.com/JianZcar)*
