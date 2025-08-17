#!/usr/bin/env bash
#
# Install Meslo LG Nerd Fonts to the user's local font directory, on Linux systems. For
# macOS, the script will skip the installation as they are installed via
# '.chezmoiexternal.toml'.
#
# NOTE:
#   I only install a small set of fonts from the '.fonts' directory. You can modify
#   the $C_FONT_FILES array to include any additional fonts you want to install.
#
# Comment Legend:
#   - A.1.: Commented out because this is the last script run by chezmoi.
#
# Hash of packages config file for change detection:
# packages.yaml hash: {{ include ".fonts/README.md" | sha256sum }}
#
############################################################################################
####[ Global Variables ]####################################################################


font_updated=false

readonly C_FONT_FILES=("MesloLGMNerdFont-Bold.ttf"
    "MesloLGMNerdFont-BoldItalic.ttf"
    "MesloLGMNerdFont-Italic.ttf"
    "MesloLGMNerdFont-Regular.ttf")

C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_YELLOW C_GREEN C_BLUE C_RED C_NC

readonly C_WARNING="${C_YELLOW}==>${C_NC} "
readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "


####[ Main ]################################################################################


echo "${C_INFO}Running font installation script..."

###
### [ Initial Checks ]
###

if [[ $(uname -s) == "Darwin" ]]; then
    echo "${C_INFO}Skipping font installation on macOS..."
    # echo ""  # A.1.
    exit 0
else
    C_FONT_DIR="$HOME/.local/share/fonts"
fi

###
### [ Font Installation ]
###

echo "${C_INFO}Installing Meslo Nerd Fonts..."

[[ ! -d $C_FONT_DIR ]] && mkdir -p "$C_FONT_DIR"

## Copy missing font files to the font directory.
for file in "${C_FONT_FILES[@]}"; do
    if [[ ! -f "$C_FONT_DIR/$file" ]]; then
        echo "${C_WARNING}Missing font file: $file"
        echo "${C_INFO}Copying '$file' to '$C_FONT_DIR'..."
        cp "$HOME/.local/share/chezmoi/.fonts/$file" "$C_FONT_DIR" \
            || echo "${C_ERROR}Failed to copy '$file' to '$C_FONT_DIR'" >&2
        font_updated=true
    fi
done

## Update the font cache if any fonts were copied.
if [[ $font_updated == true ]]; then
    if command -v fc-cache &>/dev/null; then
        echo "${C_INFO}Updating font cache..."
        fc-cache -fv
    fi
else
    echo "${C_NOTE}Meslo Nerd Fonts already present"
fi

echo "${C_SUCCESS}Font installation script completed"
# echo ""  # A.1.
