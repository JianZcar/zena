# Zena OS

Zena is a custom-built, immutable operating system based on Arch Linux, designed for exceptional performance, enhanced security, and a highly streamlined user experience. It leverages modern containerization and image-based deployment techniques to provide a robust, predictable, and efficient computing environment.

## Features

*   **Immutable Core:** Built on `bootc`, `ostree`, and `composefs`, Zena OS provides a highly stable and predictable system with a read-only root filesystem, enhancing security and reliability.
*   **Performance-Optimized Kernel:** Utilizes the `linux-cachyos-bore` kernel, featuring the BORE scheduler for superior performance and responsiveness.
*   **Dynamic Installation Flow:** Features an innovative installer-to-stable transition, where an initial installer image automatically switches to a stable release channel (`ghcr.io/zerixal/zena:stable`) on the first boot for a seamless setup experience.
*   **Modern Application Delivery:** Flatpak is fully integrated and Flathub is pre-configured, enabling easy and secure installation of sandboxed applications.
*   **Customized Desktop Environment:**
    *   **Niri Wayland Compositor:** A highly performant and modern Wayland compositor at the core of the desktop experience.
    *   **Dank Material Shell:** a Wayland desktop shell and integrated desktop environment interface built with Quickshell and Go that provides window management, a launcher, widgets, notifications.
    *   **Ghostty Terminal:** A fast and feature-rich terminal emulator for efficient command-line interaction.
    *   **Nautilus File Manager:** The intuitive and user-friendly file manager from GNOME.

## How to Install
