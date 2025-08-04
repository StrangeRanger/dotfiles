#!/usr/bin/env bash
#
# Install the cross-shell prompt, Starship.
#
############################################################################################
####[ Global Variables ]####################################################################


C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_GREEN C_BLUE C_RED C_NC

readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

C_OS="$(uname -s)"
readonly C_OS


####[ Main ]################################################################################


if [[ $C_OS == "Darwin" ]]; then
    echo "${C_NOTE}Skipping Starship installation on macOS (use Homebrew instead)"
    exit 0
fi

echo "${C_INFO}Installing cross-shell prompt, Starship..."

if [[ $EUID -ne 0 && $(uname -s) != Darwin ]]; then
    echo "${C_NOTE}This step requires administrative rights"
    read -rp "${C_NOTE}Do you want to continue? [y/N]: " answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "${C_INFO}Continuing with the operation..."
    else
        echo "${C_INFO}Operation cancelled"
        exit 0
    fi
fi

curl -sS https://starship.rs/install.sh | sh \
    && echo "${C_SUCCESS}Starship installed successfully" \
    || echo "${C_ERROR}Failed to install Starship"
