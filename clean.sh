#!/bin/sh
set -e

# Colors
L_GREEN='\033[1;32m'
L_RED='\033[1;31m'
L_BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Logging
function status {
    echo "${L_GREEN}[*]${NC}" $@
}

function exists {
    echo "${L_RED}[-]${NC}" $@
}

function restore {
    echo "${L_BLUE}[-]${NC}" $@
}

# List of symlinks to remove
declare -a LINKED=("${HOME}/.zshrc" "${HOME}/.bash_aliases" "${HOME}/.tmux" "${HOME}/.tmux.conf" "${HOME}/.vim" "${HOME}/.vimrc" "${HOME}/.cargo/env" "${HOME}/.config/karabiner/karabiner.json" "${HOME}/.config/base16_color_space.sh" "${HOME}/.rustfmt.toml")

# Delete all dotfiles-related directories
for f in "${LINKED[@]}"; do
    # Delete directories without prompt
    if [ -d ${f} ];then
        status "Removing directory ${f}"        
	rm -rf ${f}
    # Restore backups, if present
    elif [ -f ${f}.bak ];then
        restore "Restoring ${f}"
        unlink ${f}
        mv ${f}.bak ${f}
    elif [ -f ${f} ];then
        unlink ${f}
    else
        echo $f
        continue
    fi
done
