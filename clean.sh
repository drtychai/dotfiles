#!/bin/bash
set -e

# Colors
L_GREEN='\033[1;32m'
L_BLUE='\033[1;34m'
L_RED='\033[1;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# List of symlinks to remove
declare -a LINKED=(
    "${HOME}/.zshrc"
    "${HOME}/.bash_aliases"
    "${HOME}/.tmux"
    "${HOME}/.tmux.conf"
    "${HOME}/.vim"
    "${HOME}/.vimrc"
    "${HOME}/.config/zsh"
    "${HOME}/.config/cargo"
    "${HOME}/.config/karabiner/karabiner.json"
    "${HOME}/.config/base16_color_space.sh"
    "${HOME}/.config/starship.toml"
    "${HOME}/.rustfmt.toml"
)

# Logging
function info  { echo -e "${L_GREEN}[+]${NC}" $@; }
function debug { echo -e "${L_BLUE}[*]${NC}" $@; }
function error { echo -e "${L_RED}[-]${NC}" $@; }
function fatal { echo -e "${L_RED}[-]${NC}" $@ && exit 1;}

function clean_symlink {
    local trgt=${1}
    debug "Unlinking resource... ${f}"
    case "`uname -s`" in
        Darwin*)
            rm -r ${trgt} && unlink -r ${trgt} 
            ;;
        Linux*)
            unlink ${trgt}
            ;;
        *) 
            fatal "OS not supported...exiting..."
            ;;
    esac
}

function has_backup {
    local trgt=${1}
    if [ -e ${trgt}.bak ]; then
        # Restore backups, if present
        debug "Restoring backup.. ${trgt}"
        clean_symlink ${trgt}
        mv ${trgt}.bak ${trgt}
    fi 
}

function clean_local_env {
    for f in "${LINKED[@]}"; do
        # Check if resource exists
        [ ! -L ${f} ] && debug "Resource does not exist, skipping... ${f}" && continue
        
        # Recursively attempt to remove all symlinks
        [[ ! `clean_symlink ${f}` ]] && clean_local_env
    done
}

clean_local_env 2>/dev/null

info "dotfile cleanup complete"
