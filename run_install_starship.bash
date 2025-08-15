#!/usr/bin/env bash
#
# Install the cross-shell prompt, Starship.
#
############################################################################################
####[ Global Variables ]####################################################################


C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_YELLOW C_GREEN C_BLUE C_CYAN C_RED C_NC

readonly C_WARNING="${C_YELLOW}==>${C_NC} "
readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "


####[ Main ]################################################################################


if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "${C_NOTE}Skipping Starship installation on macOS"
    echo ""
    exit 0
fi

echo "${C_INFO}Installing Starship prompt..."

if (( EUID != 0 )); then
    if [[ ! -t 0 ]]; then
        echo "${C_ERROR}Non-interactive environment detected" >&2
        echo "${C_NOTE}Run interactively to install Starship"
        echo "${C_NOTE}Skipping Starship installation"
        echo ""
        exit 0
    fi

    echo "${C_NOTE}This step requires administrative rights"
    read -rp "${C_NOTE}Do you want to continue? [y/N]: " answer

    if [[ ! $answer =~ ^[yY] ]]; then
        echo "${C_WARNING}Operation cancelled" >&2
        echo ""
        exit 0
    fi
fi

curl -sS https://starship.rs/install.sh | sh \
    && echo "${C_SUCCESS}Starship installation completed" \
    || echo "${C_ERROR}Failed to install Starship" >&2
echo ""
