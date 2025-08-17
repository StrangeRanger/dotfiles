#!/usr/bin/env bash
#
# Install the Neovim text editor on Linux distributions.
#
# NOTES:
#   - Neovim is installed by 'run_onchange_install_packages.bash.tmpl' on the following:
#       - macOS
#       - Arch based distributions
#   - For other flavors of Linux, Neovim is installed without a package manager due to it
#     often falling out of date fairly quickly, missing important features and bug fixes.
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

C_TMP_DIR="$(mktemp -d)"
readonly C_TMP_DIR

case $(uname -m) in
    x86_64)  readonly C_ARCH="x86_64" ;;
    aarch64) readonly C_ARCH="arm64" ;;
    *)       readonly C_ARCH="unknown" ;;
esac

readonly C_NEOVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${C_ARCH}.tar.gz"


####[ Functions ]###########################################################################


####
# Compare the installed and latest version of Neovim.
#
# PARAMETERS:
#   - $1: latest_nvim_version (Required)
#       - The latest version of Neovim available on Github.
#
# RETURNS:
#   - 0: Neovim is not installed.
#   - 1: The most recent version of Neovim is installed.
compare_neovim_versions() {
    local latest_nvim_version="$1"
    local nvim_version_output installed_nvim_version

    if command -v nvim >/dev/null; then
        read -ra nvim_version_output < <(nvim --version  2>/dev/null)
        installed_nvim_version="${nvim_version_output[1]}"
    else
        return 0
    fi

    if [[ $installed_nvim_version != "$latest_nvim_version" ]]; then
        echo "${C_WARNING}Installed Neovim version ($installed_nvim_version) is not the" \
            "latest ($latest_nvim_version)"
    else
        echo "${C_SUCCESS}Installed Neovim version ($installed_nvim_version) is the latest"
        echo ""
        return 1
    fi
}


####[ Trapping Logic ]######################################################################


trap 'rm -rf "$C_TMP_DIR"' EXIT


####[ Checks ]##############################################################################


[[ $(uname -s) == "Darwin" ]] && exit 0
command -v pacman >/dev/null && exit 0

if [[ ! -t 0 ]]; then
    echo "${C_ERROR}Non-interactive environment detected" >&2
    echo "${C_NOTE}Run interactively to install Neovim"
    echo "${C_NOTE}Skipping Neovim installation"
    echo ""
    exit 0
fi


####[ Main ]################################################################################


echo "${C_INFO}Performing Neovim version check..."

latest_nvim_version=$(
    curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"([^"]+)".*/\1/'
)

compare_neovim_versions "$latest_nvim_version" || exit 0

echo "${C_INFO}Installing Neovim ${latest_nvim_version}..."

if (( EUID != 0 )); then
    echo "${C_NOTE}This step requires administrative rights"
    read -rp "${C_NOTE}Do you want to continue? [y/N]: " answer

    if [[ ! $answer =~ ^[yY] ]]; then
        echo "${C_WARNING}Operation cancelled" >&2
        echo ""
        exit 0
    fi
fi

curl -LO "$C_NEOVIM_URL" || {
    echo "${C_ERROR}Failed to download Neovim ${latest_nvim_version}" >&2
    exit 1
}

sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf "nvim-linux-${C_ARCH}.tar.gz"
rm "nvim-linux-${C_ARCH}.tar.gz"

echo "${C_SUCCESS}Neovim ${latest_nvim_version} installed successfully"
echo ""
