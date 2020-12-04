#!/bin/bash
set -e

# Colors
L_GREEN='\033[1;32m'
L_BLUE='\033[1;34m'
L_RED='\033[1;31m'
NC='\033[0m' # No Color

# Globals
SH=`echo ${SHELL} | cut -d '/' -f3`
DIR="$(cd "$(dirname "$0")" ; pwd -P)"

# Logging
function info  { echo -e "${L_GREEN}[*]${NC}" $@; }
function debug { echo -e "${L_BLUE}[-]${NC}" $@; }
function error { echo -e "${L_RED}[-]${NC}" $@; }

# Create a symbolic link from the file/dir in our repo to
# the local environment. If file currently exists, attempt to
# manually unlink performs recursively calls until all links created
# --> fn args are idential to symlink <SRC> <TRGT>
function symlink {
    local src_name=${1}
    local trgt_name=${2}
    if ! `ln -s ${src_name} ${trgt_name}`; then
        debug "Manually unlinking ${trgt_name}..."
        if ! `unlink -rf ${trgt_name}`; then
            error "Cannot manually unlink..."
            #exit 1
            continue
        fi
        debug "Performing recursive call to symlink fn..."
        symlink ${trgt_name}
    fi
}

function map_local_bins {
    # Add bin to PATH
    if ! grep -q 'dotfiles/bin' ${HOME}/.${SH}rc; then
    	echo "# Add dotfiles bin to PATH" >> ${HOME}/.${SH}rc
    	echo "export PATH=\${PATH}:${DIR}/bin" >> ${HOME}/.${SH}rc
    else
        error "dotfiles bin already in .${SH}rc PATH"
    fi

    # Add to path in ${HOME}/.${SH}rc
    if ! grep -q '/usr/local/sbin' ${HOME}/.${SH}rc; then
        echo "export PATH=\$PATH:/usr/local/sbin" >> ${HOME}/.${SH}rc
    else
        error "local sbin already in .${SH}rc PATH"
    fi
}

# Add alias files to path
function map_aliases {
    # Install bash aliases
    if ! grep -q bash_aliases ${HOME}/.${SH}rc; then
        echo "# Set up aliases" >> ${HOME}/.${SH}rc
        echo "[ -f \${HOME}/.bash_aliases ] && source \${HOME}/.bash_aliases" >> ${HOME}/.${SH}rc
    else
        error ".bash_aliases already in .${SH}rc"
    fi

    # Install git aliases
    if ! grep -q gitaliases ${HOME}/.gitconfig 2>/dev/null; then
        echo "[include]" >> ${HOME}/.gitconfig
        echo "	path = ~/.gitaliases" >> ${HOME}/.gitconfig
    else
        error ".gitaliases already in .gitconfig"
    fi

    # Install rust aliases
    if ! grep -q rs-aliases ${HOME}/.cargo/env 2>/dev/null; then
        echo "source ${DIR}/config/cargo/rs-aliases" >> ${HOME}/.cargo/env
    else
        error "rust aliases already in .cargo/env"
    fi
}

function map_symlinks {
    # Excluded files
    ###declare -a excluded=("README.md" "bin" "iterm2" "install.sh" "clean.sh" "config")
    # Setup symlinks
    for file in ${DIR}/*; do
      case "${file}" in
        *"README.md")
          #echo $file
          continue
          ;;
        *"bin")
          #echo $file
          continue
          ;;
        *"iterm2")
          #echo $file
          continue
          ;;
        *".sh")
          #echo $file
          continue
          ;;
        *"config")
          link_config_to_local
          ;;
        *)
          # Bail out for empty strings
          if [ -z ${file} ]; then
              continue
          else
              link
          fi
          ;;
      esac
   done
}

function link {
    local filename="$(basename $file)"
    local debug="${DIR}/.debug"
    if [[ "${filename}" != "$(basename $0)" ]]; then
        if [ -e ${HOME}/.${filename} ]; then
            if ! [ -h ${HOME}/.${filename} ]; then
                mkdir -p $debug
                # Move existing dotfile to $debug
                mv ${HOME}/.${filename} $debug/
            else
                error ".${filename} is already symlinked"
                continue
            fi
        fi
        info "Creating link for .${filename}"
        symlink ${DIR}/${filename} ${HOME}/.${filename}
    fi
}

function link_config_to_local {
    # Explicit configuration files to symlink
    local usr_conf="${HOME}/.config"
    local config_dir="${DIR}/config"

    # Setup symlinks
    for d in ${config_dir}/*; do
      case "${d}" in
        *"karabiner")
            # Only link on macOS
            local f="karabiner"
            [[ ! ${OSTYPE} == "darwin"* ]] && continue
            # Create directory if not present 
            [ ! -e ${usr_conf}/${f} ] && mkdir -p ${usr_conf}/${f}

            # Backup pre-exisiting file, if present
            if [ -f "${usr_conf}/${f}/${f}.json" ];then
                debug "Backing up resource... ${f}.json -> ${f}.json.bak"
                mv "${usr_conf}/${f}/${f}.json" "${usr_conf}/${f}/${f}.json.bak" 
            fi

            # Link: keybindings
            info "Creating link for... ${usr_conf}/${f}/${f}.json"
            symlink "${config_dir}/${f}/${f}.json" "${usr_conf}/${f}/${f}.json"
            ;;
        *"base16_color_space.sh")
            local theme_conf="${usr_conf}/base16_color_space.sh"
            info "Creating link for ${usr_conf}/base16_color_space.sh"
            symlink ${d} ${theme_conf}
            ;; 
        *"starship.toml")
            local theme_conf="${usr_conf}/starship.toml"
            info "Creating link for ${usr_conf}/starship.toml"
            symlink ${d} ${theme_conf}
            ;; 
        *)
            continue
            ;;
      esac
   done

}

function set_theme {
    BASE16_COLOR_SPACE="${HOME}/.config/base16-color-space.sh"
}

function config_shell {
    # Pull in submodules
    pushd ${DIR} >/dev/null
    git submodule init && git submodule update
    popd >/dev/null

    # Install vim plugins
    vim +'PlugInstall --sync' +qa

    # Clone Tmux Plugin Manager
    rm -rf ${HOME}/.tmux/plugins/tpm 2>&1 > /dev/null
    git clone --quiet https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
}

# SymLink dotfiles and configs
map_symlinks
map_aliases
map_local_bins
config_shell
