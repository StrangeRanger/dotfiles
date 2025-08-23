# Dotfiles

[![Project Tracker](https://img.shields.io/badge/repo%20status-Project%20Tracker-lightgrey)](https://hthompson.dev/project-tracker#project-819556518)

This repository contains my dotfiles, managed with [chezmoi](https://www.chezmoi.io/). The goal of this repository is to provide a consistent and reproducible terminal environment across **macOS** and **Linux** systems by capturing shell settings, editor preferences, and much more.

<details>
<summary><strong>Table of Contents</strong></summary>

- [Dotfiles](#dotfiles)
  - [What's Included](#whats-included)
  - [Features](#features)
    - [Cross‑Platform Support](#crossplatform-support)
    - [Automated Installation](#automated-installation)
    - [Automated Management](#automated-management)
    - [External Resource Management](#external-resource-management)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Updating](#updating)
    - [Non-Interactive Behavior](#non-interactive-behavior)
  - [Troubleshooting and Q\&A](#troubleshooting-and-qa)
  - [Configuration Files](#configuration-files)
  - [Support and Issues](#support-and-issues)
  - [License](#license)

</details>

## What's Included

- **Shell (Zsh)**: Platform‑specific configurations built on [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh). The templates, located in [.chezmoitemplates](.chezmoitemplates), define and source plugins, helper functions, and other settings.
- **Shell Prompt**: Custom [Starship](https://github.com/starship/starship) [configurations](private_dot_config/starship.toml), which define icons for many languages and OSes.
- **Editor / IDE**: [Neovim configurations](private_dot_config/nvim), with plugins managed by [vim-plug](https://github.com/junegunn/vim-plug).
- **Version Control**: A Git configuration [template](dot_gitconfig.tmpl), with [Delta](https://github.com/dandavison/delta) integration.
- **Fonts**: Meslo Nerd Font files under [.fonts](.fonts) to render terminal icons.
- **Chezmoi Data & Templates**: Data files and external resource definitions in [.chezmoidata](.chezmoidata) and [.chezmoiexternal.toml.tmpl](.chezmoiexternal.toml.tmpl).
- **Package Definitions**: [Package lists](.chezmoidata/packages.yaml) for different operating systems, used by the [package installer script](run_onchange_install_packages.bash.tmpl) to install CLI tools.

## Features

### Cross‑Platform Support

- **OS & package manager detection**: The installer scripts check the OS and choose the appropriate package manager. Unsupported systems are skipped or fail gracefully.
- **GUI awareness**: A [precompute script](run_before_01_precompute.bash.tmpl) examines the environment and caches whether a GUI session is present. Other scripts use this flag to enable or disable desktop‑specific settings.
- **Automatic template selection**: When applying the Zsh configurations, the system automatically selects the appropriate template for Linux or macOS.


### Automated Installation

- **Packages**: The [package installer script](run_onchange_install_packages.bash.tmpl) reads [packages.yaml](.chezmoidata/packages.yaml) and installs both general and OS‑specific CLI tools via pacman, apt, or Homebrew. Refer to [External Resource Management](#external-resource-management) for additional software not handled by a package manager.
- **Neovim & Starship**: On Debian-based distros, dedicated scripts ([Neovim](run_install_neovim.bash) & [Starship](run_install_starship.bash)) download the latest releases of Neovim and Starship from GitHub — package manager versions often lag behind. They compare these with the currently installed versions and install them if they're newer. On macOS and Arch, these tools are managed by a package manager.
- **Nerd fonts**: A [font installer script](run_onchange_install_fonts.bash) checks whether Meslo Nerd Font files are missing or outdated by comparing file hashes, then copies updated fonts into `~/.local/share/fonts` and refreshes the font cache. macOS users get their fonts via a Homebrew cask.
- **Default shell**: A [default shell script](run_once_set_default_shell.bash) sets Zsh as the default shell for the current user. This script only runs once, unless executed manually.

### Automated Management

- **Neovim plugin maintenance**: A [plugin‑update script](run_after_update_nvim_plugins.bash) runs whenever your Neovim configurations change or after a set amount of time has passed. It installs `vim‑plug` if it's missing and runs `PlugInstall`, `PlugUpdate`, and `TSUpdate` in headless mode to install and update plugins and tree-sitters.
- **Safe shell updates**: Before overwriting your Zsh configurations, a [drift‑detection script](run_before_02_zshrc_drift_detection.bash) extracts the managed portion of `~/.zshrc`, compares it with the current template, shows a diff, and prompts you to apply, skip, or cancel the changes.
  - **Managed portion**: The drift-detection script ignores all changes below the `chezmoi:unmodified` comment at the bottom of the `.zshrc` file. This section ensures configurations can be added without them being tracked or overwritten during updates.

### External Resource Management

- **Automated downloads**: The [.chezmoiexternal.toml.tmpl](.chezmoiexternal.toml.tmpl) file tells chezmoi to fetch and cache third‑party tools during `chezmoi apply`. It downloads `vim‑plug`, Oh My Zsh, zsh plugins, and much more.
- **Scheduled refreshes**: Each external resource defines a refresh period of 168 hours (one week), ensuring that these tools stay up to date without manual intervention.

<!-- ### Customizations

To be added later -->

## Prerequisites

These dotfiles are made for **macOS and Linux only**. Before applying them, ensure you meet the following prerequisites:

- **[chezmoi](https://www.chezmoi.io/)** for dotfiles management
- **Homebrew** (on macOS)
- **Git** (version 2.0+)
- **Bash** (version 3.2+)
- **Internet connection** for downloading external resources
- **Administrative privileges** (for package installation on Linux)

## Quick Start

1. **[Install chezmoi](https://www.chezmoi.io/install/)** (if not already installed):
    ```bash
    # macOS
    brew install chezmoi

    # Linux
    sh -c "$(curl -fsLS get.chezmoi.io)"
    ```

2. **Initialize with this repository**:
    ```bash
    chezmoi init https://github.com/StrangeRanger/dotfiles.git
    ```

3. **Preview changes** (optional):
    ```bash
    chezmoi diff
    ```

4. **Apply the dotfiles**:
    ```bash
    chezmoi apply
    ```

    > [!NOTE]
    > The first run will install packages, fonts and configure your environment. This may take a minute or two and will require administrative privileges on Linux systems.

## Updating

To update your dotfiles:

```bash
chezmoi update
```

During the update/apply process, you may see a prompt like:

```
Detected changes in '~/.zshrc' above '#### chezmoi:unmodified'.
--- current (head) vs rendered (head) diff ---
<colorized diff>
Proceed with changes? [y]es / [S]kip / [c]ancel apply:
```

**Options**:
- `y`: Apply the changes
- `s`: Skip modifying `~/.zshrc` **(Default)**
- `c`: Abort the entire apply

**Skip flag**:
- When skipping `~/.zshrc` modifications, a skip flag file is created so the modifying template leaves it as-is.
- The flag is placed at `$XDG_RUNTIME_DIR/chezmoi/skip-dot-zshrc` or `~/.cache/chezmoi/skip-dot-zshrc`. It is removed automatically on the next run.

### Non-Interactive Behavior

Some steps are intentionally skipped when no TTY is available (e.g., in CI or automated provisioning) to avoid hanging on prompts:

- `.zshrc` head drift
- Package installation
- Starship installation
- Neovim installation

These safeguards ensure unattended runs complete safely without partial or unintended configuration changes.

## Troubleshooting and Q&A

<details>
<summary><strong>Permission denied during package installation</strong></summary>

> ```bash
> # Make sure you have sudo privileges on Linux.
> sudo -v
> ```

</details>

<details>
<summary><strong>Package installation being skipped</strong></summary>

> - Non-interactive environments (like CI) skip package installation by default.
> - Chezmoi attempts to install packages only once, until the installer script or the packages list changes.
> - If you need to rerun the installer again, you can clear chezmoi's `run_onchange` state:
>   ```bash
>   chezmoi state delete-bucket --bucket=entryState
>   chezmoi apply
>   ```

</details>

<details>
<summary><strong>Fonts not appearing correctly</strong></summary>

> - Ensure your terminal supports Nerd Fonts.
> - Reinitialize font cache with `fc-cache -fv`.
> - Restart your terminal after font installation.

</details>

<details>
<summary><strong>Neovim plugins not loading</strong></summary>

> - Make sure `vim-plug` is installed.
> - Manually install/update plugins:
>   ```bash
>   nvim +PlugInstall +PlugUpdate +qall
>   ```

</details>

<details>
<summary><strong>Neovim installation issues on Linux</strong></summary>

> - Neovim only supports x86_64 and arm64 architectures.
> - Ensure you have administrative privileges for installation.
> - Check that curl is available for downloading the latest release.

</details>

<details>
<summary><strong>Starship prompt not showing</strong></summary>

> - Verify Starship is installed: `starship --version`
> - Check if Starship is initialized in your shell config.

</details>

<details>
<summary><strong>Neovim plugins not updating automatically</strong></summary>

> - The system automatically updates plugins every 7 days or when Neovim configs change.
> - To force an update: `nvim +PlugInstall +PlugUpdate +qall`

</details>

## Configuration Files

| File/Directory | Purpose |
| --- | --- |
| `.chezmoidata/packages.yaml` | Package definitions for automatic installation across platforms (general and OS‑specific packages). |
| `.chezmoiexternal.toml.tmpl` | Defines third‑party resources for Chezmoi to fetch, such as vim‑plug, Copilot Vim, Oh My Zsh, zsh plugins and a prebuilt fzf binary, with refresh schedules. |
| `.chezmoiignore` | Lists files to exclude from chezmoi management. |
| `.chezmoitemplates/zshrc_darwin.tmpl` and `zshrc_linux.tmpl` | OS‑specific Zsh templates defining environment variables, aliases and helper functions. |
| `private_dot_config/starship.toml` | Starship prompt configuration, including Nerd‑Font icons and module settings. |
| `private_dot_config/nvim/` | Neovim configuration directory (`init.vim`, `second_init.lua`) with plugin management. |
| `dot_gitconfig.tmpl` | Global Git configuration with Delta integration for enhanced diffs. |
| `modify_dot_zshrc` | Template that merges the managed head of `~/.zshrc` with the unmodified tail. |
| `run_before_02_zshrc_drift_detection.bash` | Pre‑apply hook that detects drift in `~/.zshrc` above the `#### chezmoi:unmodified` marker, shows a diff, and prompts to apply, skip or cancel. |
| `run_before_01_precompute.bash.tmpl` | Precompute script executed before apply; checks for supported OS, detects `git‑delta` and whether a GUI session is present, then writes results to `.precomputed_data.json`. |
| `run_after_update_nvim_plugins.bash` | Installs `vim‑plug` if missing and updates Neovim plugins and tree‑sitter parsers when configs change or after a set interval. |
| `run_onchange_install_packages.bash.tmpl` | Script that reads `packages.yaml` and installs general and OS‑specific CLI tools via pacman, apt, or Homebrew. |
| `run_onchange_install_fonts.bash` | Checks for missing or outdated Meslo Nerd Font files on Linux, installs them, and refreshes the font cache; skipped on macOS. |
| `run_install_neovim.bash` | Installs the latest Neovim release on Debian‑based distributions when the package manager version lags behind. |
| `run_install_starship.bash` | Installs the latest Starship release on Debian‑based distributions, skipping macOS and Arch. |
| `run_once_set_default_shell.bash` | One‑time script that sets Zsh as the default shell for the current user, ensuring it’s listed in `/etc/shells`. |

## Support and Issues

Please use [GitHub Issues](https://github.com/StrangeRanger/dotfiles/issues) for bug reports and feature requests.

## License

This project is licensed under the [MIT License](LICENSE).
