#!/usr/bin/env bash
#
# Install the cross-shell prompt, Starship, on Linux distributions.
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


####[ Functions ]###########################################################################


####
# Compare the installed and latest version of Starship.
#
# PARAMETERS:
#   - $1: latest_starship_version (Required)
#       - The latest version of Starship available on Github.
#
# RETURNS:
#   - 0: Starship is not installed.
#   - 1: The most recent version of Starship is installed.
compare_starship_versions() {
    local latest_starship_version="$1"
    local starship_version_output installed_starship_version

    if command -v starship >/dev/null; then
        read -ra starship_version_output < <(starship --version  2>/dev/null)
        installed_starship_version="${starship_version_output[1]}"
    else
        return 0
    fi

    if [[ $installed_starship_version != "$latest_starship_version" ]]; then
        echo "${C_WARNING}Installed Starship version ($installed_starship_version) is not the" \
            "latest ($latest_starship_version)"
    else
        echo "${C_SUCCESS}Installed Starship version ($installed_starship_version) is the latest"
        echo ""
        return 1
    fi
}


####[ Checks ]##############################################################################


[[ "$(uname -s)" == "Darwin" ]] && exit 0

if [[ ! -t 0 ]]; then
    echo "${C_ERROR}Non-interactive environment detected" >&2
    echo "${C_NOTE}Run interactively to install Starship"
    echo "${C_NOTE}Skipping Starship installation"
    echo ""
    exit 0
fi


####[ Main ]################################################################################


echo "${C_INFO}Performing Starship prompt version check..."

latest_starship_version=$(
    curl -s "https://api.github.com/repos/starship/starship/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"v?([^"]+)".*/\1/'
)

compare_starship_versions "$latest_starship_version" || exit 0

echo "${C_INFO}Installing Starship prompt v${latest_starship_version}..."

if (( EUID != 0 )); then
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
