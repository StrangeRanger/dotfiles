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
# Hash of .font README file for change detection:
# README.md hash: {{ include ".fonts/README.md" | sha256sum }}
#
############################################################################################
####[ Global Variables ]####################################################################


needs_update=false

readonly C_FONT_SRC="$HOME/.local/share/chezmoi/.fonts"
readonly C_FONT_DST="$HOME/.local/share/fonts"
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
    echo ""
    exit 0
fi

###
### [ Font Installation ]
###

echo "${C_INFO}Checking for missing or outdated Meslo Nerd Fonts..."

[[ ! -d $C_FONT_DST ]] && mkdir -p "$C_FONT_DST"

## Copy missing font files to the font directory.
for file in "${C_FONT_FILES[@]}"; do
    src="$C_FONT_SRC/$file"
    dst="$C_FONT_DST/$file"
    if [[ ! -f "$dst" ]]; then
        echo "${C_WARNING}Found missing font file: $file" >&2
        needs_update=true
        break
    fi

    src_hash=$(sha256sum "$src"); src_hash="${src_hash%% *}"
    dst_hash=$(sha256sum "$dst"); dst_hash="${dst_hash%% *}"
    if [[ "$src_hash" != "$dst_hash" ]]; then
        echo "${C_WARNING}Font file '$file' differs from the installed version" >&2
        needs_update=true
        break
    fi
done
unset src dst src_hash dst_hash

if [[ $needs_update == true ]]; then
    echo "${C_INFO}Copying font files to '$C_FONT_DST'..."
    cp -- "${C_FONT_FILES[@]/#/$C_FONT_SRC/}" "$C_FONT_DST" || {
        echo "${C_ERROR}Failed to copy font files" >&2
        echo ""
        exit 0
    }

    if command -v fc-cache &>/dev/null; then
        echo "${C_INFO}Updating font cache..."
        fc-cache -fv
    fi
else
    echo "${C_NOTE}Meslo Nerd Fonts already present"
fi

echo "${C_SUCCESS}Font installation script completed"
echo ""
