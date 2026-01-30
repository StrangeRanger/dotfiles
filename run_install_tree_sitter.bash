#!/usr/bin/env bash
#
# Install tree-sitter on Debian/apt-based Linux distributions. On macOS and Arch-based
# distros, tree-sitter is installed and managed via their respective package managers.
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
    x86_64)  readonly C_ARCH="x64" ;;
    aarch64) readonly C_ARCH="arm64" ;;
    *)       readonly C_ARCH="unknown" ;;
esac

readonly C_TREE_SITTER_URL="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${C_ARCH}.gz"


####[ Functions ]###########################################################################


####
# Compare the installed and latest version of tree-sitter.
#
# PARAMETERS:
#   - $1: latest_tree_sitter_version (Required)
#       - The latest version of tree-sitter available on Github.
#
# RETURNS:
#   - 0: tree-sitter is not installed.
#   - 1: The most recent version of tree-sitter is installed.
compare_tree_sitter_versions() {
    local latest_tree_sitter_version="$1"
    local tree_sitter_version_output installed_tree_sitter_version

    if command -v tree-sitter >/dev/null; then
        read -ra tree_sitter_version_output < <(tree-sitter --version  2>/dev/null)
        installed_tree_sitter_version="${tree_sitter_version_output[1]}"
    else
        return 0
    fi

    if [[ $installed_tree_sitter_version != "$latest_tree_sitter_version" ]]; then
        echo "${C_WARNING}Installed tree-sitter version ($installed_tree_sitter_version)" \
            "is not the latest ($latest_tree_sitter_version)"
    else
        echo -e "${C_SUCCESS}Installed tree-sitter version" \
            "($installed_tree_sitter_version) is the latest\n"
        return 1
    fi
}


####[ Trapping Logic ]######################################################################


trap 'rm -rf "$C_TMP_DIR"' EXIT


####[ Main ]################################################################################


echo "${C_INFO}Running tree-sitter installation script..."

###
### [ Initial Checks ]
###

if [[ $(uname -s) == "Darwin" ]]; then
    echo "${C_INFO}Skipping tree-sitter installation on macOS..."
    echo ""
    exit 0
fi

if command -v pacman >/dev/null; then
    echo "${C_INFO}Skipping tree-sitter installation on Arch based distributions..."
    echo ""
    exit 0
fi

if [[ ! -t 0 ]]; then
    echo "${C_ERROR}Non-interactive environment detected" >&2
    echo "${C_NOTE}Run interactively to install tree-sitter"
    echo "${C_INFO}Skipping tree-sitter installation..."
    echo ""
    exit 0
fi

###
### [ tree-sitter Version Check ]
###

echo "${C_INFO}Performing tree-sitter version check..."

latest_tree_sitter_version=$(
    curl -s "https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"([^"]+)".*/\1/' \
        | sed -E 's/^v//'
)

compare_tree_sitter_versions "$latest_tree_sitter_version" || exit 0

###
### [ Install tree-sitter ]
###

echo "${C_INFO}Installing tree-sitter ${latest_tree_sitter_version}..."

if (( EUID != 0 )); then
    echo "${C_NOTE}This step requires administrative rights"
    read -rp "${C_NOTE}Do you want to continue? [y/N]: " answer

    if [[ ! $answer =~ ^[yY] ]]; then
        echo "${C_WARNING}Operation cancelled" >&2
        echo ""
        exit 0
    fi
fi

curl -LO "$C_TREE_SITTER_URL" || {
    echo "${C_ERROR}Failed to download tree-sitter ${latest_tree_sitter_version}" >&2
    exit 1
}

sudo rm -rf /opt/tree-sitter
sudo mkdir -p /opt/tree-sitter/bin
sudo gzip -d "tree-sitter-linux-${C_ARCH}.gz"
sudo mv "tree-sitter-linux-${C_ARCH}" /opt/tree-sitter/bin/tree-sitter

sudo chmod 0755 /opt/tree-sitter/bin/tree-sitter
sudo chown -R root:root /opt/tree-sitter

echo "${C_SUCCESS}tree-sitter installation script completed"
echo ""
