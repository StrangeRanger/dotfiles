#!/usr/bin/env bash
#
# Install the cross-shell prompt, Starship.
#
########################################################################################

C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_RED C_NC C_ERROR


echo "Installing cross-shell prompt, Starship..."
curl -sS https://starship.rs/install.sh | sh || {
    echo "${C_ERROR}Failed to install Starship"
}

