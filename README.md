# Zena OS

Zena OS is a custom Fedora-based operating system built with **bootc**. It uses an immutable, container-native approach and ships with **systemd-homed** for secure home directory management out of the box.

## Key Features

* **Systemd-Homed Enabled by Default**: User home directories are managed by `systemd-homed`, giving you secure, encrypted, and portable home directories with modern user identity management. systemd-homed simplifies account creation and supports multiple storage formats (including LUKS2 and fscrypt), and makes homes portable and easier to manage compared to traditional `/etc/passwd` home layouts.

> **Note:** On initial setup, the user’s home directory will be created as a LUKS‑encrypted volume with a btrfs filesystem inside by default, offering encrypted storage and flexible filesystem features.

* **Niri Compositor**: A modern and efficient Wayland compositor that optimizes performance and smoothness for everyday desktop tasks.

* **Dank Material Shell**: A tailored desktop user interface layer providing dynamic bars, smart notifications, and a clean user experience.

* **Optimized Performance**: Custom system settings and kernel tunings designed to give responsive system performance for both desktop and development workflows.

* **Container-Native and Immutable**: Built on the bootc model, the OS delivers atomic updates and reliable rollback support. System components are delivered as containers, making the base system stable and reproducible.

* **Gaming Support (Coming Soon)**: Planned enhancements to improve performance and compatibility for gaming workloads.
