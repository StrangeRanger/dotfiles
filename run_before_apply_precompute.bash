#!/usr/bin/env bash
#
# Processes to run before applying the dotfiles.
#
########################################################################################
####[ Global Variables ]################################################################


C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_NC="$(printf '\033[0m')"
readonly C_BLUE C_NC

readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "


####[ Main ]############################################################################


echo "${C_INFO}Running precompute script..."

echo "${C_INFO}  Checking if git-delta is installed..."
# Check if git-delta is installed.
if command -v delta >/dev/null; then
    C_IS_DELTA_INSTALLED=true
else
    C_IS_DELTA_INSTALLED=false
fi

echo "${C_INFO}  Checking if GUI environment is present..."
# Check for GUI environment. (Specific to Linux)
if pidof gdm >/dev/null \
    || pidof lightdm >/dev/null \
    || pidof sddm >/dev/null \
    || pidof xorg >/dev/null \
    || pidof wayland >/dev/null \
    || [[ -n $DISPLAY ]] \
    || [[ $XDG_SESSION_TYPE == "wayland" ]] \
    || [[ $XDG_SESSION_TYPE = "x11" ]]
then
    C_IS_GUI_ENVIRONMENT=true
else
    C_IS_GUI_ENVIRONMENT=false
fi

echo "${C_INFO}  Writing precomputed data to file..."
cat <<EOF > "$HOME/.local/share/chezmoi/.precomputed_data.json"
{
    "isDeltaInstalled": $C_IS_DELTA_INSTALLED,
    "isGUIEnvironment": $C_IS_GUI_ENVIRONMENT
}
EOF

echo "${C_SUCCESS}Precompute script completed"

