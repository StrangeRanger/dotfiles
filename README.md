# Dotfiles

[![Project Tracker](https://img.shields.io/badge/repo%20status-Project%20Tracker-lightgrey)](https://hthompson.dev/project-tracker#project-819556518)

This repository contains my personal dotfiles and terminal configurations, managed with [chezmoi](https://www.chezmoi.io/). These configurations provide a consistent terminal environment across macOS and Linux systems.

<details>
<summary><strong>Table of Contents</strong></summary>

- [Dotfiles](#dotfiles)
  - [What's Included](#whats-included)
  - [Features](#features)
    - [Cross-Platform Support](#cross-platform-support)
    - [Automated Setup](#automated-setup)
    - [Customizable](#customizable)
  - [Prerequisites](#prerequisites)
    - [Optional but Recommended](#optional-but-recommended)
  - [Quick Start](#quick-start)
  - [What Happens During Installation](#what-happens-during-installation)
  - [Updating](#updating)
    - [Non-Interactive Behavior](#non-interactive-behavior)
  - [Customization](#customization)
    - [Key Customization Points](#key-customization-points)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
  - [Configuration Files](#configuration-files)
  - [Support and Issues](#support-and-issues)
  - [License](#license)

</details>

## What's Included

- **Shell Configuration**: Zsh with [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) and platform-specific customizations
- **Prompt**: [Starship](https://starship.rs/) prompt with custom configurations and automated version management
- **Editor**: [Neovim](https://github.com/neovim/neovim) configurations with [vim-plug](https://github.com/junegunn/vim-plug), automated plugin management, and automated version management on Linux systems
- **Git**: Global Git configurations with [Delta](https://github.com/dandavison/delta) integration for enhanced diffs
- **Font Management**: Automated [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) installation for terminal icons
- **Package Management**: Cross-platform package installation and management with intelligent dependency handling
- **Environment Detection**: Smart detection of GUI vs headless environments
- **External Resource Management**: Templated external resource configuration with platform-specific tooling (fzf on Linux)
- **Selective File Management**: Partial management of `~/.zshrc` (only the section above a marker line is managed; everything beneath is preserved across applies)

## Features

### Cross-Platform Support

- Automatic OS detection for macOS and Linux
- Platform-specific configurations and package installations
- Conditional templating for different environments

### Automated Setup

- Font installation (Nerd Fonts for terminal icons)
- Package installation based on your system (Homebrew, pacman, apt)
- Starship prompt installation and configuration with version checking
- Neovim setup with vim-plug, automated plugin updates, and automated version management on non-Arch Linux systems
- Oh My Zsh installation with useful plugins
- Git Delta setup for enhanced diff viewing
- External tool installation (fzf on Linux systems)
- Environment-aware configurations (GUI vs headless)
- Safe drift detection & confirmation prompt for the managed head of `~/.zshrc`

### Customizable

The configuration uses chezmoi templates, making it easy to:
- Add personal customizations
- Handle different machine configurations
- Manage secrets and private configurations

## Prerequisites

- **[chezmoi](https://www.chezmoi.io/)** for dotfiles management
- **Git** (version 2.0+)
- **Zsh** (recommended shell, will be configured automatically)
- **Bash** (version 3.0+)
- **Internet connection** for downloading external resources
- **Administrative privileges** (for package installation on Linux)

### Optional but Recommended
- [1Password](https://1password.com/) for Git commit signing
- Terminal with Nerd Font support for icons

## Quick Start

1. **Install chezmoi** (if not already installed):
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
   > The first run will install packages, fonts, and configure your environment. This may take a minute or two and will require administrative privileges on Linux systems.

## What Happens During Installation

The setup process will automatically:

1. **Install Oh My Zsh** and useful plugins (autosuggestions, syntax highlighting, etc.)
2. **Install Starship prompt** and configure it with `private_dot_config/starship.toml` (includes automated version management on Linux)
3. **Install packages** based on your system (see `.chezmoidata/packages.yaml`)
4. **Install Nerd Fonts** for terminal icons and better appearance
5. **Configure Neovim** with vim-plug and install/update plugins (includes automated version management on Linux)
6. **Set up Git** with Delta for enhanced diff viewing (if available)
7. **Install external tools** like fzf (on Linux systems) for enhanced functionality
8. **Configure shell environment** with platform-specific optimizations
9. **Manage only the head of `~/.zshrc`** – a `modify_` template and a pre-apply hook ensure:
    - The portion of the file above the marker line `#### chezmoi:unmodified` is regenerated from templates.
    - Everything below that marker (locally appended or tool-managed content) is left untouched.
    - If the current head has drifted, you are shown a colorized diff and can proceed, skip just that change, or cancel the apply.

## Updating

To update your dotfiles:

```bash
chezmoi update
```

This will pull the latest changes from the repository and apply them to your system.

During update/apply you may see a prompt like:

```
Detected changes in ~/.zshrc above '#### chezmoi:unmodified'.
--- current (head) vs rendered (head) diff ---
<colorized diff>
Proceed with 'chezmoi apply'? [y]es / [S]kip / [c]ancel apply:
```

**Options**:
- `y` – Apply the updated managed head
- `s` – Skip modifying `~/.zshrc` this run (a skip flag file is created so the modify template leaves it as-is)
- `c` – Abort the entire apply

**Default / no input**:
- Pressing Enter (blank input) or running non-interactively defaults to `s` (skip). The rest of the apply continues as normal.

**Skip flag path**:
- `$XDG_RUNTIME_DIR/chezmoi/skip-dot-zshrc` (fallback: `~/.cache/chezmoi/skip-dot-zshrc`). It is cleared automatically on the next run.

### Non-Interactive Behavior

Some steps are intentionally skipped when no TTY is available (e.g. in CI or automated provisioning) to avoid hanging on privilege prompts:

- **`.zshrc` head drift**: Defaults to skip (managed head left untouched) and writes the skip flag. Re-run interactively to apply the change.
- **Package installation**: Skipped with a notice if user input would be required (Linux privilege escalation) and stdin is not a TTY.
- **Starship installation (when not root)**: Skipped if the environment is not interactive.

These safeguards ensure unattended runs complete safely without partial or unintended configuration changes.

## Customization

To customize these dotfiles for your own use:

1. **Fork this repository**
2. **Modify the configuration files** as needed:
   - Edit `dot_gitconfig.tmpl` to change Git user information
   - Update `.chezmoidata/packages.yaml` to add/remove packages
   - Customize `private_dot_config/starship.toml` for prompt appearance
   - Modify Neovim configs in `private_dot_config/nvim/`
3. **Update the chezmoi source**:
   ```bash
   chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git
   ```

### Key Customization Points

- **Git Configuration**: Update user name, email, and signing key in `dot_gitconfig.tmpl`
- **Package Lists**: Modify packages in `.chezmoidata/packages.yaml`
- **Shell Aliases**: Add custom aliases in the appropriate `.zshrc_*.tmpl` files
- **Starship Prompt**: Customize appearance in `private_dot_config/starship.toml`
- **`~/.zshrc` Tail Section**: Add or modify personal/tool-managed commands *below* the marker `#### chezmoi:unmodified`; they will be preserved.
- **Marker Line**: If you change the marker text, update both `modify_dot_zshrc` and `run_before_02_modify_dot_zshrc.bash.tmpl`.
- **Skip Behavior**: To force a skip non-interactively, create the skip flag file noted above before running `chezmoi apply`.

## Troubleshooting

### Common Issues

**Permission denied during package installation**
```bash
# Make sure you have sudo privileges on Linux.
sudo -v
```

**Fonts not appearing correctly**
- Ensure your terminal supports Nerd Fonts
- Restart your terminal after font installation

**Neovim plugins not loading**
```bash
# Manually update plugins.
nvim +PlugInstall +PlugUpdate +qall
```

**Neovim installation issues on Linux**
- The script automatically detects your architecture (x86_64/arm64)
- Ensure you have administrative privileges for installation
- Check that curl is available for downloading the latest release

**Starship prompt not showing**
- Verify Starship is installed: `starship --version`
- The installation script checks for the latest version automatically
- Check if Starship is initialized in your shell config

**Git commit signing issues**
- Ensure 1Password CLI is installed and configured
- Verify SSH key is added to your Git provider

## Configuration Files

| File/Directory | Purpose |
|---|---|
| `.chezmoidata/packages.yaml` | Package definitions for automatic installation across platforms |
| `.chezmoiexternal.toml.tmpl` | Templated external resources (Oh My Zsh, plugins, vim-plug, platform-specific tools) |
| `.chezmoiignore` | Files to exclude from chezmoi management |
| `.chezmoitemplates/.zshrc_{darwin,linux}.tmpl` | OS-specific Zsh templates |
| `private_dot_config/starship.toml` | Starship prompt configuration |
| `private_dot_config/nvim/` | Neovim editor configuration and plugins |
| `dot_gitconfig.tmpl` | Global Git configuration with Delta integration |
| `modify_dot_zshrc` | `modify_` template merging managed head with preserved tail below marker |
| `run_before_02_modify_dot_zshrc.bash` | Pre-apply drift check & prompt for `~/.zshrc` head with enhanced template rendering |
| `run_install_neovim.bash` | Neovim installation script for Linux distributions with automated version management |
| `run_install_starship.bash` | Starship installation script with version comparison and Linux-specific handling |
| `run_*.bash.tmpl` | Setup and maintenance scripts (packages, font installation, etc.) |

## Support and Issues

Please use [GitHub Issues](https://github.com/StrangeRanger/dotfiles/issues) for bug reports and feature requests.

## License

This project is licensed under the [MIT License](LICENSE).
