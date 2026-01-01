# Zena OS

Zena OS is a custom Fedora‑based operating system built with **bootc**. It uses an immutable, container‑native approach and ships with **systemd‑homed** for secure home directory management out of the box, and a **Cachy kernel compiled with Link‑Time Optimization (LTO)** for performance enhancements.

## Key Features

* **Ships with a Cachy Kernel LTO Build:** The default kernel is compiled with **Link‑Time Optimization (LTO)** enabled, applying whole‑kernel compiler optimizations at link time to improve execution performance across system workloads. See the **CachyOS Kernel** documentation for details on how LTO contributes to performance improvements. [CachyOS Kernel Features (includes LTO)](https://wiki.cachyos.org/features/kernel)

* **Systemd-Homed Enabled by Default**: User home directories are managed by `systemd-homed`, giving you secure, encrypted, and portable home directories with modern user identity management. systemd-homed simplifies account creation and supports multiple storage formats (including LUKS2 and fscrypt), and makes homes portable and easier to manage compared to traditional `/etc/passwd` home layouts.

> **Note:** On initial setup, the user’s home directory will be created as a LUKS‑encrypted volume with a btrfs filesystem inside by default, offering encrypted storage and flexible filesystem features.

* **Niri Compositor**: A modern and efficient Wayland compositor that optimizes performance and smoothness for everyday desktop tasks.

* **Dank Material Shell**: A tailored desktop user interface layer providing dynamic bars, smart notifications, and a clean user experience.

* **Optimized Performance**: Custom system settings and kernel tunings designed to give responsive system performance for both desktop and development workflows.

* **Nix Package Manager**: Ships with Nix, enabling reproducible builds, user-level package management, and isolation of software environments.

* **Container-Native and Immutable**: Built on the bootc model, the OS delivers atomic updates and reliable rollback support. System components are delivered as containers, making the base system stable and reproducible.

* **Gaming Support (Coming Soon)**: Planned enhancements to improve performance and compatibility for gaming workloads.

## Initial Setup
![Initial Setup](https://i.imgur.com/NY27oy9.png)

* **To use podman**, first run these command `homectl with $(whoami) add-subuids` and `podman system migrate` once then run podman.

## Dank Material Shell
<div align="center">

https://github.com/user-attachments/assets/1200a739-7770-4601-8b85-695ca527819a

</div>

<details><summary><strong>More Screenshots</strong></summary>

<div align="center">

<img src="https://github.com/user-attachments/assets/203a9678-c3b7-4720-bb97-853a511ac5c8" width="600" alt="Desktop" />

<img src="https://github.com/user-attachments/assets/a937cf35-a43b-4558-8c39-5694ff5fcac4" width="600" alt="Dashboard" />

<img src="https://github.com/user-attachments/assets/2da00ea1-8921-4473-a2a9-44a44535a822" width="450" alt="Launcher" />

<img src="https://github.com/user-attachments/assets/732c30de-5f4a-4a2b-a995-c8ab656cecd5" width="600" alt="Control Center" />

</div>

</details>

## Niri
<div align="center">

https://github.com/YaLTeR/niri/assets/1794388/bce834b0-f205-434e-a027-b373495f9729

</div>
