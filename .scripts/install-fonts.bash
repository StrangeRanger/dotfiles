#!/usr/bin/env bash
#
# Install MesloLGS NF fonts.
#
########################################################################################

font_updated=false

C_OS=$(uname -s)
C_FONT_FILES=("MesloLGS NF Bold Italic.ttf"
              "MesloLGS NF Bold.ttf"
              "MesloLGS NF Italic.ttf"
              "MesloLGS NF Regular.ttf")


echo "Installing MesloLGS NF fonts..."

if [[ "$C_OS" == "Darwin" ]]; then
  # Location on macOS.
  FONT_DIR="$HOME/Library/Fonts"
else
  # Location on Linux.
  FONT_DIR="$HOME/.local/share/fonts"
fi

## Create the font directory if it does not exist.
[[ ! -d $FONT_DIR ]] && mkdir -p "$FONT_DIR"

## Copy missing font files to the font directory.
for file in "${C_FONT_FILES[@]}"; do
    if [[ ! -f "$FONT_DIR/$file" ]]; then
        echo "Missing font: $file"
        echo "Copying $file to $FONT_DIR"
        cp "$HOME/.local/share/chezmoi/.fonts/$file" "$FONT_DIR"
        font_updated=true
    fi
done

## Update the font cache if any fonts were copied.
if [[ $font_updated == true ]] && hash fc-cache 2>/dev/null; then
    fc-cache -fv
fi

