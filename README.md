# Zena OS

Zena OS is a custom Fedora‑based operating system built with **bootc**. It is immutable and container‑native, designed for reproducibility, developer productivity, and a responsive desktop experience. Zena OS ships with `systemd-homed` for secure, portable home directories and a **Cachy kernel** compiled with Link‑Time Optimization (LTO) for improved performance.

---

## Table of contents

1. Project overview
2. Key features
3. System requirements
4. Installation
5. Initial setup (first boot)
6. Zix - Lightweight Nix profile manager
7. systemd-homed and home storage details
8. Podman and homectl notes
9. Configuration & customization
10. Security considerations
11. Development & contributing
12. Roadmap
13. License
14. Contact & support

---

## Project overview

Zena OS delivers an immutable desktop operating system optimized for developer workflows and reproducibility. Key design principles:

* **Atomic & container-native** - core system components are delivered as container images and updated atomically with rollback support via the `bootc` model.
* **Secure & portable homes** - `systemd-homed` is enabled by default to provide portable, encrypted home directories.
* **Reproducible development environment** - Nix is included for reproducible builds and per-user package management.
* **Developer friendly** - small utilities and tooling (for example, `zix`) simplify common developer workflows.

---

## Key features

* **Cachy Kernel (LTO)** - kernel built with Link‑Time Optimization to improve performance.
* **systemd-homed by default** - encrypted LUKS homes with btrfs by default (configurable to fscrypt or plain directories).
* **[Niri compositor](https://github.com/YaLTeR/niri)** — Wayland compositor tuned for responsiveness and efficiency.
* **[Dank Material Shell](https://danklinux.com)**  A modern and beautiful desktop shell with dynamic theming and smooth animations.
* **Nix + Zix** - Nix available system‑wide; `zix` provided as a lightweight per‑user convenience for `nix profile` operations.
* **Immutable, containerized base** - atomic updates, containerized services, and simple rollback semantics.
* **Podman friendly** - guidance for subordinate UID/GID mapping and unprivileged containers.

---

## System requirements

Minimum recommended hardware for a pleasant desktop experience:

* 64‑bit x86_64 CPU (modern Intel/AMD recommended)
* 8 GB RAM (16 GB recommended for heavy development/gaming workloads)
* 20 GB free disk for system images + user storage (additional space required for encrypted LUKS homes)
* UEFI firmware (Secure Boot optional; see Roadmap)

Notes:
* Zena OS targets desktop and workstation hardware. Virtual machines are supported, but GPU passthrough and hardware acceleration may need extra configuration.

---

## Installation

> This README documents the high-level install and first-time setup flows. For production deployments or customized builds, consult the `docs/` directory and release artifacts in the `releases/` page.

### Typical install flow

1. Download the latest ISO/installer image from the project releases or artifact storage.
2. Create a bootable USB (e.g., `dd`, balenaEtcher, Rufus).
3. Boot the target machine from the installer image and follow the installer prompts.

Installer options include:
* Target disk selection and partitioning
* Enable LUKS encryption for the system.

### Switching to Zena OS from an existing bootc system

If you are already running a bootc-based system and want to switch to Zena OS, you can rebase the system image using `bootc switch`:

```bash
bootc switch ghcr.io/zerixal/zena:latest
```

---

## Initial setup (first boot)

On first boot the system presents a TUI setup that collects basic account and system settings. The TUI options are:

* **Create Account** - create your primary user (username and passphrase). Homed user creation is performed via `systemd-homed`.
* **Set Home Size** - choose the size for the encrypted home container (uses Luks, other options will be added in future update).
* **Set Timezone** - select the system timezone.

After the TUI completes, and login in, perform these recommended steps:

1. Verify `systemd-homed` provisioned your account:

```bash
homectl show $(whoami)
```

Review storage, encryption, and home-size fields.

2. Configure subordinate UID/GID ranges for unprivileged containers (Podman):

```bash
sudo homectl with $(whoami) add-subuids
```

3. Migrate Podman storage (run once per user):

```bash
podman system migrate
```

4. Install per-user packages:
* Use Bazaar, the dedicated GUI app store for Flatpak applications.
* Use `zix` (see below) or `nix profile` for reproducible per‑user packages.

---

## Zix - Lightweight Nix profile manager

`zix` is a small CLI wrapper included to simplify common `nix profile` operations for users who want a faster, opinionated surface.

### Basic commands

* `zix add <package>...` - install package(s) to the current user profile
* `zix remove <package>...` - remove package(s) from the profile
* `zix list` - list installed packages in the current profile
* `zix search <term>` - search `nixpkgs`

Examples:

```bash
zix add ripgrep fd
zix remove ripgrep
zix list
zix search python
```

Implementation notes:
* `zix` forwards to `nix profile` subcommands and handles common error messaging.
* Advanced users should use the `nix` CLI directly for complex workflows.

---

## systemd-homed and home storage details

Zena OS enables `systemd-homed` by default to provide portable, encrypted homes that are easy to create, modify, and export.

### Default configuration

* **Storage format:** LUKS2 container with a btrfs filesystem by default (provides snapshots and subvolumes).
* **Alternatives:** fscrypt-backed homes are supported when LUKS is not desired.

Administration:

* Inspect a homed account: `homectl show <username>`
* List homed accounts: `homectl list`
* Create or modify homed users: `homectl create` / `homectl update`

---

## Podman and homectl notes

For proper unprivileged container behavior, configure subordinate UID/GID mappings and migrate podman storage when appropriate.

1. Add subordinate UID/GID ranges to the homed account (example above).
2. Confirm `/etc/subuid` and `/etc/subgid` contain expected ranges for the user.
3. Run a one-time storage migration:

```bash
podman system migrate
```

If you encounter permission issues, re-check `homectl` entries and subordinate ranges.

---

## Configuration & customization

Common customization points:

* **User profile packages:** use `zix` or `nix profile`.
* **Desktop:** customize Dank Material Shell and compositor via `~/.config`.

---

## Security considerations

* **Home encryption:** Use strong passphrases.
* **Atomic updates & rollbacks:** Use `bootc` to perform atomic updates; if a regression occurs, use `bootc` or the bootloader to restore a previous image.
* **Service exposure:** Validate firewall rules and prefer unprivileged namespaces for network‑facing workloads.
* **Secure Boot:** Work in progress - see Roadmap.

---

## Development & contributing

We welcome contributions.

### How to contribute

1. Fork the repository and create a feature branch.
2. Open a pull request with a clear description of changes and rationale.
3. Include tests or a short verification plan when applicable.

---

## Roadmap

Short‑to‑mid term items:
* Gaming packages.
* Secure Boot support.
* Improvements to the TUI installer.

---

## License

See the `LICENSE` file in the repository for licensing details.

---

## Contact & support

For issues and feature requests, open an issue in the GitHub repository. Provide logs, steps to reproduce, and relevant hardware details.


