#!/bin/bash
set -e

# Colors
L_GREEN='\033[1;32m'
L_RED='\033[1;31m'
L_BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Globals
SH=`echo ${SHELL} | cut -d '/' -f3`
DIR="$(cd "$(dirname "$0")" ; pwd -P)"

# Logging
function status {
    echo -e "${L_GREEN}[*]${NC}" $@
}

function exists {
    echo -e "${L_RED}[-]${NC}" $@
}

function backup {
    echo -e "${L_BLUE}[-]${NC}" $@
}

function map_local_bins {
    # Add bin to PATH
    if ! grep -q 'dotfiles/bin' ${HOME}/.${SH}rc; then
    	echo "# Add dotfiles bin to PATH" >> ${HOME}/.${SH}rc
    	echo "export PATH=\${PATH}:${DIR}/bin" >> ${HOME}/.${SH}rc
    else
        exists "dotfiles bin already in .${SH}rc PATH"
    fi

    # Add to path in ${HOME}/.${SH}rc
    if ! grep -q '/usr/local/sbin' ${HOME}/.${SH}rc; then
        echo "export PATH=\$PATH:/usr/local/sbin" >> ${HOME}/.${SH}rc
    else
        exists "local sbin already in .${SH}rc PATH"
    fi
}

# Add alias files to path
function map_aliases {
    # Install bash aliases
    if ! grep -q bash_aliases ${HOME}/.${SH}rc; then
        echo "# Set up aliases" >> ${HOME}/.${SH}rc
        echo "[ -f \${HOME}/.bash_aliases ] && source \${HOME}/.bash_aliases" >> ${HOME}/.${SH}rc
    else
        exists ".bash_aliases already in .${SH}rc"
    fi

    # Install git aliases
    if ! grep -q gitaliases ${HOME}/.gitconfig 2>/dev/null; then
        echo "[include]" >> ${HOME}/.gitconfig
        echo "	path = ~/.gitaliases" >> ${HOME}/.gitconfig
    else
        exists ".gitaliases already in .gitconfig"
    fi

    # Install rust aliases
    if ! grep -q rs-aliases ${HOME}/.cargo/env 2>/dev/null; then
        echo "source ${DIR}/config/cargo/rs-aliases" >> ${HOME}/.cargo/env
    else
        exists "rust aliases already in .cargo/env"
    fi
}

function map_symlinks {
    # Excluded files
    #declare -a excluded=("README.md" "bin" "iterm2" "install.sh" "clean.sh" "config")

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
    local backup="${DIR}/.backup"
    if [[ "${filename}" != "$(basename $0)" ]]; then
        if [ -e ${HOME}/.${filename} ]; then
            if ! [ -h ${HOME}/.${filename} ]; then
                mkdir -p $backup
                # Move existing dotfile to $backup
                mv ${HOME}/.${filename} $backup/
            else
                exists .${filename} is already symlinked
                continue
            fi
        fi
        status "Creating link for .${filename}"
        ln -s ${DIR}/${filename} ${HOME}/.${filename}
    fi
}

function link_config_to_local {
    # Explicit configuration files to symlink
    #declare -a included=("cargo" "karabiner")
    local usr_conf="${HOME}/.config"
    local config_dir="${DIR}/config"

    # Setup symlinks
    for d in ${config_dir}/*; do
      case "${d}" in
        *"cargo")
            # Create directory if not present 
            if [ ! -e ${HOME}/.cargo ];then
                # Install rust
                #install_rust
                mkdir -p ${HOME}/.cargo 
            fi
           
            # Link: env, aliases
            #declare -a lnk_array=("env" "rs-aliases")
            declare -a lnk_array=("env")
            for f in "${lnk_array[@]}"; do
                if [ -f "${HOME}/.cargo/${f}" ];then
	            backup "Backing up ~/.cargo/${f}"
		    mv ${HOME}/.cargo/${f} ${HOME}/.cargo/${f}.bak
	        fi
		status "Creating link for ~/.cargo/${f}"
                ln -s ${config_dir}/${f} ${HOME}/.cargo/${f}
            done

            # Link: rustfmt config
            local rs_fmt="rustfmt.toml"
            if [ -f "${HOME}/.${rs_fmt}" ];then
                backup "Backing up rustfmt.toml"
		mv "${HOME}/.${rs_fmt}" "${HOME}/.${rs_fmt}.bak"
            fi
            status "Creating link for ~/.rustfmt.toml"
            ln -s ${config_dir}/${d}/${rs_fmt} ${HOME}/.${rs_fmt}
            ;;

        *"karabiner")
            # Only link on macOS
            if [[ ! ${OSTYPE} == "darwin"* ]];then
                continue
            fi

            local f="karabiner"
            # Create directory if not present 
            if [ ! -e ${usr_conf}/${f} ];then
                mkdir -p ${usr_conf}/${f}
            # Backup config if present
            elif [ -f "${usr_conf}/${f}/${f}.json" ];then
                backup "Backing up karabiner.json"
                mv "${usr_conf}/${f}/${f}.json" "${usr_conf}/${f}/${f}.json.bak" 
            fi

            # Link: keybindings
            status "Creating link for ~/.config/${f}/${f}.json"
            ln -s "${config_dir}/${f}/${f}.json" "${usr_conf}/${f}/${f}.json"
            ;;
        *"base16_color_space.sh")
            local theme_conf="${HOME}/.config/base16_color_space.sh"
            status "Creating link for ~/.config/base16_color_space.sh"
            ln -s ${d} ${theme_conf}
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

    # Custom zsh prompt
    if [ "${SH}" == "zsh" ] && ! grep -q 'PROMPT+' ${HOME}/.${SH}rc;then
        echo -ne "\n# Custom zsh prompt\n" >> ${HOME}/.${SH}rc
        echo "PROMPT=\"%(?:%{\$fg_bold[green]%}%m ➜:%{\$fg_bold[red]%}%m ➜)\"" >> ${HOME}/.${SH}rc
        echo "PROMPT+=' %{\$fg[cyan]%}%c%{\$reset_color%} \$(git_prompt_info)'" >> ${HOME}/.${SH}rc
    else
        exists "Custom PROMPT already set"
    fi
}

# SymLink dotfiles and configs
map_symlinks
map_aliases
map_local_bins
config_shell
