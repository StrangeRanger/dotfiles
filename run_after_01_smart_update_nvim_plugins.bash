#!/usr/bin/env bash
#
# Automatically install and update vim-plug plugins. This script runs when Neovim
# config files change OR the plugins haven't been updated within a certain period of time.
#
############################################################################################
####[ Global Variables ]####################################################################


C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_YELLOW C_GREEN C_BLUE C_RED C_CYAN C_NC

readonly C_WARNING="${C_YELLOW}==>${C_NC} "
readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

readonly C_PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
# Path to the file that tracks the last time the plugins were updated.
readonly C_UPDATE_MARKER="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/last_plugin_update"
readonly C_UPDATE_INTERVAL_DAYS=7


####[ Functions ]###########################################################################


####
# Check if plugins need updating based on the time since last update.
#
# RETURNS:
#   - 0: Plugins should be updated (either no marker or outdated).
#   - 1: Plugins should not be updated (marker exists and updated recently).
should_update_plugins() {
    local last_update_time

    if [[ ! -f "$C_UPDATE_MARKER" ]]; then
        echo "${C_NOTE}No previous update marker found"
        echo "${C_INFO}Updating plugins..."
        return 0
    fi

    if ! last_update_time=$(
        if [[ $(uname -s) == "Darwin" ]]; then stat -f %m "$C_UPDATE_MARKER"
        else                                   stat -c %Y "$C_UPDATE_MARKER"
        fi );
    then
        echo "${C_ERROR}Failed to get last update time from marker file" >&2
        echo "${C_INFO}Skipping plugin updates..."
        return 1
    fi

    local current_time; current_time=$(date +%s)
    local time_diff=$((current_time - last_update_time))
    local days_since_update=$((time_diff / 86400))

    echo "${C_NOTE}Plugins last updated '$days_since_update' day(s) ago"

    if (( days_since_update >= C_UPDATE_INTERVAL_DAYS )); then
        return 0
    fi

    return 1
}


####[ Main ]################################################################################


echo "${C_INFO}Running Neovim plugin script..."

if ! command -v nvim &>/dev/null; then
    echo "${C_WARNING}Neovim is not installed or not found in PATH"
    echo "${C_INFO}Skipping plugin check..."
    echo ""
    exit 0
fi

## vim-plug should already be installed by '.chezmoiexternal.toml'. This is a safeguard to
## ensure it exists.
if [[ ! -f "$C_PLUG_PATH" ]]; then
    echo "${C_INFO}Installing vim-plug..."
    if ! curl -fLo "$C_PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    then
        echo "${C_ERROR}Failed to install vim-plug" >&2
        echo ""
        exit 0
    fi
    echo "${C_SUCCESS}vim-plug installed successfully"
fi

if should_update_plugins; then
    echo "${C_INFO}Installing/updating plugins..."

    # Run PlugInstall, PlugUpdate, and TSUpdate in headless mode.
    if nvim --headless +PlugInstall +PlugUpdate +TSUpdate +qall 2>/dev/null; then
        echo "${C_SUCCESS}Neovim plugins installed/updated successfully"
        cat > "$C_UPDATE_MARKER" << EOF
DO NOT MODIFY THIS FILE

This file is automatically managed by the chezmoi script:
run_after_01_smart_update_nvim_plugins.bash

Modifying this file will affect how the script determines when Neovim plugins
were last updated, potentially causing plugins to be updated more frequently
than intended.

Last plugin update: $(date +%Y-%m-%dT%H:%M:%S)
EOF
    else
        echo "${C_ERROR}Failed to install/update Neovim plugins"
        echo ""
        exit 0
    fi
else
    echo "${C_NOTE}Skipping plugin update (run within $C_UPDATE_INTERVAL_DAYS days)"
fi

echo "${C_SUCCESS}Neovim plugin script completed"
echo ""
