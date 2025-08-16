#!/usr/bin/env bash
#
# Protect' ~/.zshrc' from unintended overwrites by chezmoi when the file has drifted from
# chezmoi’s managed source, but only for the part of the file above the $C_MARK line.
# Anything below $C_MARK is considered user-editable and ignored.
#
############################################################################################
####[ Global Variables ]####################################################################


readonly C_MARK='#### chezmoi:unmodified'
readonly C_TARGET="$HOME/.zshrc"
readonly C_FLAG_DIR="${XDG_RUNTIME_DIR:-$HOME/.cache}/chezmoi"
readonly C_SKIP_FLAG="$C_FLAG_DIR/skip-dot-zshrc"

C_TMP_DIR="$(mktemp -d)"
readonly C_TMP_DIR
readonly C_CURRENT_HEAD="$C_TMP_DIR/current_head"
readonly C_TMPL_HEAD="$C_TMP_DIR/template_head"
readonly C_RENDERED_TMPL="$C_TMP_DIR/template_render"

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

case "$(uname -s)" in
    Darwin)
        C_TMPL_NAME=".zshrc_darwin.tmpl"
        ;;
    Linux)
        C_TMPL_NAME=".zshrc_linux.tmpl"
        ;;
    *)
        echo "${C_ERROR}Unsupported OS: $(uname -s)"
        echo ""
        exit 0
        ;;
esac


####[ Functions ]###########################################################################


####
# Display the difference between two files using delta, git, or diff.
#
# ARGUMENTS:
#   - $1: file_one (Required)
#   - $2: file_two (Required)
show_diff() {
    local file_one="$1"
    local file_two="$2"

    if command -v delta &>/dev/null; then
        diff -u --label current --label rendered "$file_one" "$file_two" | delta --paging=never
    elif command -v git &>/dev/null; then
        git --no-pager diff --no-index -- "$file_one" "$file_two"
    else
        diff -u --label current --label rendered "$file_one" "$file_two"
    fi
}


####[ Trapping Logic ]######################################################################


trap 'rm -rf "$C_TMP_DIR"' EXIT


####[ Prepping ]############################################################################


[[ ! -d "$C_FLAG_DIR" ]] && mkdir -p "$C_FLAG_DIR"
[[ -f "$C_SKIP_FLAG" ]] && rm -rf "$C_SKIP_FLAG"  # Remove stale skip flag from previous run.

if [[ ! -f "$C_TARGET" ]]; then
    echo "${C_WARNING}No existing '~/.zshrc' found"
    echo ""
    exit 0
fi


####[ Main ]################################################################################


echo "${C_INFO}Running '~/.zshrc' head drift check..."

# Extract the "current head", up to $C_MARK, from the actual ~/.zshrc on disk.
awk -v mark="$C_MARK" 'index($0, mark){exit} {print}' "$C_TARGET" > "$C_CURRENT_HEAD"

# NOTE: 'chezmoi execute-template' is used instead of 'chezmoi cat' because the latter
#   caused chezmoi lock file conflicts on Linux systems.
if ! chezmoi execute-template "{{ includeTemplate \"$C_TMPL_NAME\" }}" > "$C_RENDERED_TMPL"
then
    echo "${C_ERROR}Failed to render template '$C_TMPL_NAME'."
    echo ""
    exit 0
fi

# Now extract the head from the successfully rendered template.
awk -v mark="$C_MARK" 'index($0, mark){exit} {print}' "$C_RENDERED_TMPL" > "$C_TMPL_HEAD"

## Exit if there is no drift.
if cmp -s "$C_CURRENT_HEAD" "$C_TMPL_HEAD"; then
    echo "${C_SUCCESS}No changes detected in '~/.zshrc' above '$C_MARK'."
    echo ""
    exit 0
fi

echo "${C_WARNING}Detected changes in '~/.zshrc' above '$C_MARK'."
echo "${C_CYAN}--- current (head) vs rendered (head) diff ---${C_NC}"
show_diff "$C_CURRENT_HEAD" "$C_TMPL_HEAD"
echo ""

if [[ -t 0 ]]; then
    read -r -p "${C_NOTE}Proceed with 'chezmoi apply'? [y]es / [S]kip / [c]ancel apply: " answer

    case "$answer" in
        [yY]*)
            echo "${C_NOTE}Changes will be applied to '~/.zshrc'"
            echo ""
            ;;
        [cC]*)
            echo "${C_WARNING}Cancelling 'chezmoi apply'"
            echo ""
            exit 1
            ;;
        *)
            echo "${C_NOTE}Skipping 'chezmoi apply'"
            echo ""
            : > "$C_SKIP_FLAG"
            ;;
    esac
else
    echo "${C_ERROR}Non-interactive apply and head drift detected" >&2
    echo "${C_NOTE}Skipping 'chezmoi apply'"
    echo "${C_NOTE}Run interactively to apply changes"
    echo ""
    : > "$C_SKIP_FLAG"
fi
