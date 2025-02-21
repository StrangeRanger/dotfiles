#!/usr/bin/env bash
#
# Install MesloLGS NF fonts.
#
########################################################################################
####[ Global Variables ]################################################################


font_updated=false

C_OS=$(uname -s)
C_FONT_FILES=("MesloLGS NF Bold Italic.ttf"
              "MesloLGS NF Bold.ttf"
              "MesloLGS NF Italic.ttf"
              "MesloLGS NF Regular.ttf")
readonly C_OS C_FONT_FILES

C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_YELLOW C_GREEN C_BLUE C_RED C_NC

readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_WARNING="${C_YELLOW}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "


####[ Main ]############################################################################


echo "${C_INFO}Installing MesloLGS NF fonts..."

if [[ "$C_OS" == "Darwin" ]]; then
  # Font folder location on macOS.
  C_FONT_DIR="$HOME/Library/Fonts"
else
  # Font folder location on Linux.
  C_FONT_DIR="$HOME/.local/share/fonts"
fi

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
    echo "${C_SUCCESS}MesloLGS NF fonts installed successfully"
else
    echo "${C_SUCCESS}MesloLGS NF fonts are already installed"
fi

