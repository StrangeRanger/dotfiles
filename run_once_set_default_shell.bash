#!/usr/bin/env bash
#
# Set the default shell to Zsh for the current user.
#
############################################################################################
####[ Global Variables ]####################################################################


C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_YELLOW C_GREEN C_BLUE C_RED C_CYAN C_NC

readonly C_WARNING="${C_YELLOW}==>${C_NC} "
readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

if [[ $(uname -s) == "Darwin" ]]; then
    if { brew ls --version zsh && [[ -f "$(brew --prefix)/bin/zsh" ]]; } &>/dev/null; then
        C_ZSH_PATH="$(brew --prefix)/bin/zsh"
    else
        C_ZSH_PATH="$(command -v zsh)"
    fi
else
    C_ZSH_PATH="$(command -v zsh)"
fi
readonly C_ZSH_PATH


####[ Main ]################################################################################


echo "${C_INFO}Running set default shell script..."

###
### [ Initial Checks ]
###

echo "${C_INFO}Checking for Zsh installation and current shell..."

if [[ ! -f $C_ZSH_PATH ]]; then
    echo "${C_ERROR}Zsh is not installed" >&2
    echo "${C_NOTE}Please install Zsh first before setting the default shell"
    echo ""
    exit 0
fi

if [[ $SHELL == "$C_ZSH_PATH" ]]; then
    echo "${C_NOTE}Zsh is already set as the default shell"
    echo ""
    exit 0
fi

echo "${C_INFO}Checking if '$C_ZSH_PATH' is a valid shell..."
if ! cat /etc/shells | grep "$C_ZSH_PATH" &>/dev/null; then
    echo "${C_WARNING}'$C_ZSH_PATH' isn't a valid shell listed in '/etc/shells'" >&2
    read -rp "${C_NOTE}Would you like to add it as a valid shell? [y/N]: " answer

    if [[ ! $answer =~ ^[Yy] ]]; then
        echo "${C_WARNING}Operation cancelled" >&2
        echo ""
        exit 0
    fi

    echo "$C_ZSH_PATH" | sudo tee -a /etc/shells
fi

###
### [ Change Default Shell ]
###

echo "${C_INFO}Changing default shell to Zsh ('$C_ZSH_PATH')..."
chsh -s "$C_ZSH_PATH" || {
    echo "${C_ERROR}Failed to change default shell" >&2
    echo ""
    exit 0
}

echo "${C_SUCCESS}Set default shell script completed"
echo "${C_NOTE}You'll need to log out and back in for the changes to take effect."

echo ""
