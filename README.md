<div align="center">
  <img width="256" height="256" alt="zena-logo" src="https://github.com/user-attachments/assets/82db85b8-b2a6-4899-b977-bae9b966c944" />
  
  [![Discord Invite](https://img.shields.io/badge/Join_Discord-Chat_with_us-blue?style=social&logo=discord)](https://discord.gg/22MFgGgjG9)
</div>  

# Zena

Zena is an operating system built with **bootc**. It is immutable and container‑native, designed for reproducibility, developer productivity, and a responsive desktop experience. Zena ships with `systemd-homed` for secure, portable home directories and a **Cachy kernel** compiled with Link‑Time Optimization (LTO) for improved performance.

---

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/e07900a3-0b7a-4ec4-90cc-f5452eb53279" />

## Table of contents

1. Project overview
2. Key features
3. System requirements
4. Installation
5. Initial setup (first boot)
6. Zix - Lightweight Nix profile manager
7. Gaming (opt-in)
8. systemd-homed and home storage details
9. Podman, Distrobox and homectl notes
10. Configuration & customization
11. Security considerations
12. Development & contributing
13. Roadmap
14. License
15. Contact & support

---

## Project overview

Zena delivers an immutable desktop operating system optimized for developer workflows and reproducibility. Key design principles:

* **Atomic & container-native** - The os is delivered as an image and updated atomically with rollback support via the `bootc` model.
* **Fedora-based (currently tracking Fedora 43)** - Zena uses Fedora as its base, inheriting its toolchain, and ecosystem.
* **Rapid, image-based updates** - Updates are delivered daily, and sometimes multiple times per day, while remaining fully atomic and rollback-safe.
* **Secure & portable homes** - `systemd-homed` is enabled by default to provide portable, encrypted home directories.
* **Reproducible development environment** - Nix is included for reproducible builds and per-user package management.
* **Developer friendly** - Nix! and Containers! all the tooling you need.

---

## Key features

* **[Cachy Kernel (LTO)](https://wiki.cachyos.org/features/kernel/)** - kernel built with Link‑Time Optimization to improve performance.
* **[systemd-homed](https://systemd.io/HOME_DIRECTORY/) by default** - encrypted LUKS homes with btrfs by default (configurable to fscrypt or plain directories).
* **[Niri](https://github.com/YaLTeR/niri/)** - A wayland compositor. Windows are arranged in columns on an infinite strip going to the right.
* **[Dank Material Shell](https://danklinux.com/)** -  A modern and beautiful desktop shell with dynamic theming and smooth animations.
* **[Nix](https://nixos.org/guides/how-nix-works/) + Zix** - Nix a package manager available system‑wide; `zix` provided as a lightweight per‑user convenience for `nix profile` operations.
* **Immutable, [Bootc](https://bootc-dev.github.io/bootc/)** - atomic updates, and simple rollback.
* **[Podman](https://podman.io/) friendly** - guidance for subordinate UID/GID mapping and unprivileged containers. 
* **Gaming (opt-in)** - an optional CLI-managed gaming environment that creates and manages a Distrobox named `Gaming`, and installs common gaming tools and launchers automatically. See the Gaming (opt-in) section for details.

## System requirements

Minimum recommended hardware for a pleasant desktop experience:

* 64-bit x86_64 CPU (modern Intel/AMD recommended)
* 8 GB RAM (16 GB recommended for heavy development/gaming workloads)
* 128 GB free disk for system images + user storage (additional space required for encrypted LUKS homes)
* UEFI firmware (Secure Boot optional; see Roadmap)

Notes:

* Zena targets laptop, desktop and workstation hardware.
* Supported Nvidia GPUs (GTX 16xx and RTX series)
* For gaming, a modern discrete GPU is strongly recommended.
* See Security considerations section on how to enable secureboot.

## Installation

### Typical install flow

1. Download the latest ISO/installer image from Gofile [link](https://gofile.io/d/jfK9Iz), Send.now [link](https://send.now/a/1C5A) or from the GitHub Actions artifact storage.
2. Create a bootable USB (e.g., `dd`, balenaEtcher, Rufus).
3. Boot the target machine from the installer image and follow the installer prompts.

Installer options include:

* Target disk selection and partitioning
* Enable LUKS encryption for the system

Switching to Zena from an existing bootc system:

```
bootc switch ghcr.io/zena-linux/zena:latest
```

## Initial setup (first boot)

On first boot the system presents a TUI setup that collects basic account and system settings. The TUI options are:

* Create Account - create your primary user (username and passphrase). Homed user creation is performed via `systemd-homed`.
* Set Home Size - choose the size for the encrypted home container (uses LUKS; other options will be added later).
* Select Timezone - select the system timezone.

After the TUI completes and you log in, perform these recommended steps:

1. Verify `systemd-homed` provisioned your account:

```
homectl show $(whoami)
```

Review storage, encryption, and home-size fields.

2. Configure subordinate UID/GID ranges for unprivileged containers (Podman):

```
sudo homectl with $(whoami) add-subuids
```

3. Migrate Podman storage (run once per user):

```
podman system migrate
```

4. Make sure you are using latest update:

```
sudo bootc upgrade
```

5. Install per-user packages:

* Use Bazaar, the dedicated GUI app store for Flatpak applications.
* Use `zix` (see below) or `nix profile` for reproducible per-user packages.

## Zix - Lightweight Nix profile manager

`zix` is a small CLI wrapper included to simplify common `nix profile` operations for users who are new to Nix and want an easy CLI.

### Basic commands

* `zix add <package>...` - install package(s) to the current user profile
* `zix remove <package>...` - remove package(s) from the profile
* `zix list` - list installed packages in the current profile
* `zix search <term>` - search `nixpkgs`

Examples:

```
zix add ripgrep fd
zix remove ripgrep
zix list
zix search python
```

Implementation notes:

* `zix` forwards to `nix profile` subcommands and handles common error messaging.
* Advanced users should use the `nix` CLI directly for complex workflows.

## Gaming (opt-in)

Zena includes an optional gaming feature implemented as a small CLI wrapper named `gaming`. This feature is opt-in: it is not enabled by default and requires the user to run `gaming install` to provision the gaming environment.

> **Note**: The performance is still native, So don't worry :>

### Objectives

* Provide a convenient, reproducible gaming environment isolated from the main immutable system image.
* Create a Distrobox container named `Gaming` that contains common gaming tools and launchers (Heroic, Lutris, Steam, ProtonUp-Qt, gOverlay, etc.).
* Expose desktop entries for GUI launchers so installed apps integrate with the desktop environment.
* Allow easy lifecycle management: install, uninstall, upgrade, and enter the gaming container.

### What `gaming` does

When you run `gaming install` it will:

1. Create a Distrobox instance named `Gaming`: a persistent, first-class container workspace for gaming.
2. Inside the `Gaming` Distrobox:

   * Install a curated set of gaming tools and launchers.
   * Register desktop files on the host (so Heroic, Lutris, Steam, etc. appear in the host application launcher).
3. Leave the `Gaming` Distrobox image in a state where the user can run `gaming enter` to open an interactive shell connected into the Distrobox (or `distrobox enter Gaming` directly).

When you run `gaming uninstall`, the utility will:

* Remove the `Gaming` Distrobox and all installed packages inside it.
* Removes exported apps and binaries.

When you run `gaming upgrade`, the utility will:

* Update package lists inside the `Gaming` Distrobox and upgrade packages to their latest available versions.

When you run `gaming enter`, the utility will:

* Open an interactive shell into the `Gaming` Distrobox (equivalent to `distrobox enter Gaming`) so you can run launchers or manage the environment manually.

### Troubleshooting

* If a launcher appears but does not start, run the launcher from a terminal to inspect errors (use `gaming enter` for the containerized launchers).
* Ensure user subordinate UID/GID ranges are configured (`homectl with $(whoami) add-subuids`) as described in the initial setup section.
* If Steam shows black, Disable GPU acceleration on steam settings via system tray.

## systemd-homed and home storage details

Zena enables `systemd-homed` by default to provide portable, encrypted homes that are easy to create, modify, and export.

### Default configuration

* Storage format: LUKS2 container with a btrfs filesystem by default (provides snapshots and subvolumes).
* Alternatives: fscrypt-backed homes are supported when LUKS is not desired.

Administration:

* Inspect a homed account: `homectl show <username>`
* List homed accounts: `homectl list`
* Create or modify homed users: `homectl create` / `homectl update`

## Podman, Distrobox and homectl notes

For proper unprivileged container behavior, configure subordinate UID/GID mappings and migrate Podman storage when appropriate.

1. Add subordinate UID/GID ranges to the homed account:

```
sudo homectl with $(whoami) add-subuids
```

2. Confirm `/etc/subuid` and `/etc/subgid` contain expected ranges for the user.
3. Run a one-time storage migration:

```
podman system migrate
```

If you encounter permission issues, re-check `homectl` entries and subordinate ranges.

## Configuration & customization

Common customization points:

* User profile packages: use `zix` or `nix profile`.
* Desktop: customize Dank Material Shell and Niri via DMS Settings or `~/.config`.
* Gaming: after `gaming install`, you can further customize the `Gaming` Distrobox by entering it and installing additional packages or configuring Proton/GEs manually.

## Security considerations

* **Home encryption:** Use strong passphrases.
* **Atomic updates & rollbacks:** Use `bootc` to perform atomic updates; if a regression occurs, use `bootc` or the bootloader to restore a previous image.
* **Service exposure:** Validate firewall rules and prefer unprivileged namespaces for network‑facing workloads.
* **Secure Boot:** Secure Boot is now supported. To enable it for your system, follow these steps:

1. Import the public MOK certificate:

```bash
sudo mokutil --import /secureboot/MOK.der
```

You will be prompted to set a temporary password.

2. Reboot your machine. During boot the **MOK Manager** will appear:

   * Choose **Enroll MOK**.
   * Enter the password set during import.
   * Confirm and finish enrollment, then reboot again.

3. Verify the enrollment:

```bash
sudo mokutil --sb-state
sudo mokutil --list-enrolled
```

`--sb-state` should report `SecureBoot enabled` once firmware is in User Mode and Secure Boot is active. Your kernel and module signatures will then be trusted.

---

## Development & contributing

We welcome contributions.

### How to contribute

1. Fork the repository and create a feature branch.
2. Open a pull request with a clear description of changes and rationale.
3. Include tests or a short verification plan when applicable.

## Roadmap

Short-to-mid term items:

* Default Flatpaks (optional, toggle via initial setup)
* Improvements to the TUI `zena-setup`

## License

See the `LICENSE` file in the repository for licensing details.

## Contact & support

For issues and feature requests, open an issue in the GitHub repository. Provide logs, steps to reproduce, and relevant hardware details.
