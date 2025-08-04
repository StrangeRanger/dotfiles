#!/usr/bin/env bash
#
# Install MesloLGS NF fonts.
#
############################################################################################
####[ Global Variables ]####################################################################


font_updated=false

C_OS=$(uname -s)
# Modify with the your prefered Meslo Nerd Font files, from within the .fonts directory.
C_FONT_FILES=("MesloLGMNerdFont-Bold.ttf"
    "MesloLGMNerdFont-BoldItalic.ttf"
    "MesloLGMNerdFont-Italic.ttf"
    "MesloLGMNerdFont-Regular.ttf")
readonly C_OS C_FONT_FILES

C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_YELLOW C_GREEN C_BLUE C_RED C_NC

readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_WARNING="${C_YELLOW}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "


####[ Main ]################################################################################


if [[ "$C_OS" == "Darwin" ]]; then
    echo "${C_NOTE}Skipping font installation on macOS..."
    exit 0
else
  # Font folder location on Linux.
  C_FONT_DIR="$HOME/.local/share/fonts"
fi

echo "${C_INFO}Installing Meslo Nerd Fonts to '$C_FONT_DIR'"

## Create the font directory if it does not exist.
[[ ! -d $C_FONT_DIR ]] && mkdir -p "$C_FONT_DIR"

## Copy missing font files to the font directory.
for file in "${C_FONT_FILES[@]}"; do
    if [[ ! -f "$C_FONT_DIR/$file" ]]; then
        echo "${C_WARNING}Missing font: $file"
        echo "${C_INFO}Copying $file to $C_FONT_DIR"
        cp "$HOME/.local/share/chezmoi/.fonts/$file" "$C_FONT_DIR" || {
            echo "${C_ERROR}Failed to copy $file to $C_FONT_DIR"
            exit 1
        }
        font_updated=true
    fi
done

## Update the font cache if any fonts were copied.
if [[ $font_updated == true ]] && command -v fc-cache >/dev/null; then
    fc-cache -fv
    echo "${C_SUCCESS}Meslo Nerd Fonts installed successfully"
else
    echo "${C_SUCCESS}Meslo Nerd Fonts are already installed"
fi
