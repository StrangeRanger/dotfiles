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
  - [Customization](#customization)
    - [Key Customization Points](#key-customization-points)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
  - [Configuration Files](#configuration-files)
  - [License](#license)

</details>

## What's Included

- **Shell Configuration**: Zsh with [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) and platform-specific customizations
- **Prompt**: [Starship](https://starship.rs/) prompt with custom configurations
- **Editor**: [Neovim](https://github.com/neovim/neovim) configurations with [vim-plug](https://github.com/junegunn/vim-plug) and automated plugin management
- **Git**: Global Git configurations with [Delta](https://github.com/dandavison/delta) integration for enhanced diffs
- **Font Management**: Automated [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) installation for terminal icons
- **Package Management**: Cross-platform package installation and management
- **Environment Detection**: Smart detection of GUI vs headless environments

## Features

### Cross-Platform Support

- Automatic OS detection for macOS and Linux
- Platform-specific configurations and package installations
- Conditional templating for different environments

### Automated Setup

- Font installation (Nerd Fonts for terminal icons)
- Package installation based on your system (Homebrew, pacman, apt)
- Starship prompt installation and configuration
- Neovim setup with vim-plug and automated plugin updates
- Oh My Zsh installation with useful plugins
- Git Delta setup for enhanced diff viewing
- Environment-aware configurations (GUI vs headless)

### Customizable

The configuration uses chezmoi templates, making it easy to:
- Add personal customizations
- Handle different machine configurations
- Manage secrets and private configurations

## Prerequisites

- [chezmoi](https://www.chezmoi.io/) for dotfiles management
- Git (version 2.0+)
- Zsh (recommended shell, will be configured automatically)
- Internet connection for downloading external resources
- Administrative privileges (for package installation on Linux)

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
   > The first run will install packages, fonts, and configure your environment. This may take several minutes and will require administrative privileges on Linux systems.

## What Happens During Installation

The setup process will automatically:

1. **Install Oh My Zsh** and useful plugins (autosuggestions, syntax highlighting, etc.)
2. **Install Starship prompt** and configure it with `private_dot_config/starship.toml`
3. **Install packages** based on your system (see `.chezmoidata/packages.yaml`)
4. **Install Nerd Fonts** for terminal icons and better appearance
5. **Configure Neovim** with vim-plug and install/update plugins
6. **Set up Git** with Delta for enhanced diff viewing (if available)
7. **Configure shell environment** with platform-specific optimizations

## Updating

To update your dotfiles:

```bash
chezmoi update
```

This will pull the latest changes from the repository and apply them to your system.

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

**Starship prompt not showing**
- Verify Starship is installed: `starship --version`
- Check if Starship is initialized in your shell config

**Git commit signing issues**
- Ensure 1Password CLI is installed and configured
- Verify SSH key is added to your Git provider

## Configuration Files

| File/Directory | Purpose |
|---|---|
| `.chezmoidata/packages.yaml` | Package definitions for automatic installation across platforms |
| `.chezmoiexternal.toml` | External resources (Oh My Zsh, plugins, vim-plug) |
| `.chezmoiignore` | Files to exclude from chezmoi management |
| `.scripts/` | Custom utility scripts (font installation, etc.) |
| `private_dot_config/starship.toml` | Starship prompt configuration |
| `private_dot_config/nvim/` | Neovim editor configuration and plugins |
| `dot_gitconfig.tmpl` | Global Git configuration with Delta integration |
| `dot_zshrc.tmpl` | Main Zsh configuration (platform-aware) |
| `run_*.bash.tmpl` | Setup and maintenance scripts for automated installation |

## Support and Issues

Please use [GitHub Issues](https://github.com/StrangeRanger/dotfiles/issues) for bug reports and feature requests.

## License

This project is licensed under the [MIT License](LICENSE).
