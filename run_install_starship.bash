#!/usr/bin/env bash
#
# Install the cross-shell prompt, Starship.
#
########################################################################################
####[ Global Variables ]################################################################


## Used to colorize output.
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_RED C_NC

## Short-hand colorized messages.
readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "


####[ Main ]############################################################################


echo "${C_INFO}Installing cross-shell prompt, Starship..."
curl -sS https://starship.rs/install.sh | sh \
    && echo "${C_SUCCESS}Starship installed successfully" \
    || echo "${C_ERROR}Failed to install Starship"
