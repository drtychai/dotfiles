#!/bin/bash
set -e

# Colors
L_GREEN='\033[1;32m'
L_RED='\033[1;31m'

L_GREY='\033[2;49;39m'
GREY='\033[0;49;90m'

L_BLUE='\033[1;34m'
BLUE='\033[0;34m'

NC='\033[0m' # No Color

# Globals
SH="$(echo ${SHELL} | cut -d '/' -f3)"
DIR="$(pwd -P)"

# Logging
function info    { echo -e "${L_GREEN}[+] $@ ${NC}"; }
function debug   { echo -e  "${L_GREY}[*] $@ ${NC}"; }
function error   { echo -e    "${GREY}[-] $@ ${NC}"; }
function prompt { echo -ne "${L_GREEN}[+] $@ ${NC}"; }

function fatal   { echo -e   "${L_RED}[-] $@ ${NC}" && exit 1; }
function success { echo -e "${L_GREEN}[+] $@ ${NC}" && exit 0; }

# Create a symbolic link from the file/dir in our repo to
# the local environment. If file currently exists, attempt to
# manually unlink performs recursively calls until all links created
# --> fn args are idential to symlink <SRC> <TRGT>
function symlink {
    local src_name="${1}"
    local trgt_name="${2}"
    [[ "${trgt_name}" == *"install"* ]] && return
   
    local buf_space="%$(expr 35 - `echo "${src_name/${DIR}/.}" | wc -c | xargs`)s"

    #debug "Linking: ${src_name##*/} => ${trgt_name/${HOME}/~}"
    local debug_msg="Linking: "
    debug_msg="${debug_msg}${src_name/${DIR}/.}"
    debug_msg="${debug_msg}`printf ${buf_space}`"
    debug_msg="${debug_msg}=> "
    debug_msg="${debug_msg}${trgt_name/${HOME}/~}"

    debug ${debug_msg}

    if [[ ! `ln -s ${src_name} ${trgt_name}` ]];then
        # Error throw in call
	    #debug "Manually linking ${trgt_name}..." 
        [[ ! `unlink ${trgt_name}` ]] && ln -s ${src_name} ${trgt_name} 
    fi
}

function map_local_bins {
    # Add bin to PATH
    if ! grep -q 'dotfiles/bin' ${HOME}/.${SH}rc; then
    	echo "# Add dotfiles bin to PATH" >> ${HOME}/.${SH}rc
    	echo "export PATH=\${PATH}:${DIR}/bin" >> ${HOME}/.${SH}rc
    #else error "dotfiles bin already in .${SH}rc PATH"
    fi

    # Add to path in ${HOME}/.${SH}rc
    if ! grep -q '/usr/local/sbin' ${HOME}/.${SH}rc; then
        echo "export PATH=\$PATH:/usr/local/sbin" >> ${HOME}/.${SH}rc
    #else error "local sbin already in .${SH}rc PATH"
    fi
}

# Add alias files to path
function map_aliases {
    # Install bash aliases
    if ! grep -q bash_aliases ${HOME}/.${SH}rc; then
        echo "# Set up aliases" >> ${HOME}/.${SH}rc
        echo "[ -f \${HOME}/.bash_aliases ] && source \${HOME}/.bash_aliases" >> ${HOME}/.${SH}rc
    #else error ".bash_aliases already in .${SH}rc"
    fi

    # Install git aliases
    if ! grep -q gitaliases ${HOME}/.gitconfig 2>/dev/null; then
        echo "[include]" >> ${HOME}/.gitconfig
        echo "	path = ~/.gitaliases" >> ${HOME}/.gitconfig
    #else error ".gitaliases already in .gitconfig"
    fi

    # Default to skip installation if timeout is triggered 
    prompt "Install modern CLI (rust) binaries? [y/N]:"
    read -t 5 response;

    case "${response}" in
        [yY][eE][sS]|[yY]) 
            if ! grep -q rs-aliases ${HOME}/.cargo/env 2>/dev/null; then
                echo "source ${DIR}/config/cargo/rs-aliases" >> ${HOME}/.cargo/env
            #else error "rust aliases already in .cargo/env"
            fi
                
            declare -a RS_BINS=(
                "exa"
                "bat" 
                "zoxide" 
                "starship" 
                "tokei" 
                "du-dust" 
                "fd-find" 
                "sd" 
                "grex" 
                "ripgrep"
                "bottom"
                "cw"
            )
	        cargo install -j`nproc` ${RS_BINS[@]}
            ;;
        [nN][oO]|[nN])
            ;;
        *)
            ;;
    esac
}

function map_symlinks {
    # Excluded files
    declare -a EXCLUDED=( "README.md" "bin" "iterm2" "install" "clean" )

    # Setup symlinks
    for file in $(ls ${DIR}); do
        IFS=@
        case "@${EXCLUDED[*]}@" in 
          *"@${file}@"*)
            continue
            ;;
          *) # current file is not excluded; so we must symlink it
            case ${file} in
              *"config")
                link_config_to_local
                ;;
              *"install"*)
                continue
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
            ;;
        esac
   done

   # SymLink dotfiles and configs
   symlink "${DIR}/bash_aliases" "${HOME}/.bash_aliases"
   symlink "${DIR}/zshrc" "${HOME}/.zshrc"
}

function link {
    local filename="$(basename $0)"
    local debug="${DIR}/.debug"

    if [[ "${filename}" != "$(basename $file)" ]]; then
        if [ -e ${HOME}/.${filename} ]; then
            if ! [ -h ${HOME}/.${filename} ]; then
                mkdir -p $debug
                # Move existing dotfile to $debug
                mv ${HOME}/.${filename} $debug/
            #else error ".${filename} is already symlinked"
            fi
        else
	    case "${filename}" in
              *"install"*)
                  ;;
              *)
                  symlink ${DIR}/${filename} ${HOME}/.${filename}
                  ;;
            esac
        fi
    fi
}

function link_config_to_local {
    # Explicit configuration files to symlink
    local usr_conf="${HOME}/.config"
    local config_dir="${DIR}/config"

    # Setup symlinks
    for d in ${config_dir}/*; do
      case "${d}" in
        *"zsh")
            local conf_dir="${usr_conf}/zsh"
            symlink ${d} ${conf_dir}
            ;;
        *"karabiner")
            # Only link on macOS
            local f="karabiner"
            [[ ! ${OSTYPE} == "darwin"* ]] && continue
            # Create directory if not present 
            [ ! -e ${usr_conf}/${f} ] && mkdir -p ${usr_conf}/${f}

            # Backup pre-exisiting file, if present
            if [ -f "${usr_conf}/${f}/${f}.json" ];then
                #debug "Backing up resource... ${f}.json -> ${f}.json.bak"
                mv "${usr_conf}/${f}/${f}.json" "${usr_conf}/${f}/${f}.json.bak" 
            fi

            # Link: keybindings
            symlink "${config_dir}/${f}/${f}.json" "${usr_conf}/${f}/${f}.json"
            ;;
        *"zathura")
            # Only link on macOS
            local f="zathura"
            [[ ! ${OSTYPE} == "darwin"* ]] && continue
            # Create directory if not present 
            [ ! -e ${usr_conf}/${f} ] && mkdir -p ${usr_conf}/${f}

            # Backup pre-exisiting file, if present
            if [ -f "${usr_conf}/${f}/${f}rc" ];then
                #debug "Backing up resource... ${f}rc -> ${f}rc.bak"
                mv "${usr_conf}/${f}/${f}rc" "${usr_conf}/${f}/${f}rc.bak" 
            fi

            # Link: keybindings
            symlink "${config_dir}/${f}/${f}rc" "${usr_conf}/${f}/${f}rc"
            ;;
        *"base16_color_space.sh")
            local conf="${usr_conf}/base16_color_space.sh"
            symlink ${d} ${conf}
            ;; 
        *"starship.toml")
            local conf="${usr_conf}/starship.toml"
            symlink ${d} ${conf}
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

    ln -s ${DIR}/vimrc ${HOME}/.vimrc
    ln -s ${DIR}/vim ${HOME}/.vim

    ln -s ${DIR}/tmux.conf ${HOME}/.tmux.conf

    # Clone Tmux Plugin Manager
    rm -rf ${HOME}/.tmux/plugins/tpm 2>&1 > /dev/null
    git clone --quiet https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
}

info "Linking dotfiles..."

unlink ${HOME}/.zshrc 
bash ${DIR}/clean.sh > /dev/null
bash ${DIR}/clean.sh > /dev/null

# Make ${HOME}/.config and ${HOME}/.cargo if not present
mkdir -p ${HOME}/.config
mkdir -p ${HOME}/.cargo

map_symlinks

map_aliases
map_local_bins
config_shell

success "Dotfile linking complete"
