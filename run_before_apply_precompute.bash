#!/usr/bin/env bash
#
# Processes to run before applying the dotfiles.
#
########################################################################################

echo "Running precompute script..."

echo "    Checking if git-delta is installed..."
# Check if git-delta is installed.
if hash delta 2>/dev/null; then
    IS_DELTA_INSTALLED=true
else
    IS_DELTA_INSTALLED=false
fi

echo "    Checking if GUI environment is present..."
# Check for GUI environment. (Specific to Linux)
if pidof gdm > /dev/null \
    || pidof lightdm > /dev/null \
    || pidof sddm > /dev/null \
    || pidof xorg > /dev/null \
    || pidof wayland > /dev/null \
    || [[ -n $DISPLAY ]] \
    || [[ $XDG_SESSION_TYPE == "wayland" ]] \
    || [[ $XDG_SESSION_TYPE = "x11" ]]
then
    IS_GUI_ENVIRONMENT=true
else
    IS_GUI_ENVIRONMENT=false
fi

echo "    Writing precomputed data to file..."
cat <<EOF > "$HOME/.local/share/chezmoi/.precomputed_data.json"
{
    "isDeltaInstalled": $IS_DELTA_INSTALLED,
    "isGUIEnvironment": $IS_GUI_ENVIRONMENT
}
EOF

