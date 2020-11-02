# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

# oh-mu-zsh, rust, and go environment vars
source $ZSH/oh-my-zsh.sh

export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec

# Set up aliases
[ -f ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh
[ -f ${HOME}/.bash_aliases ] && source ${HOME}/.bash_aliases
[ -f ${HOME}/.cargo/env ] && source ${HOME}/.cargo/env

# Add dotfiles bin to PATH
export PATH=${PATH}:${pwd}/bin
export PATH=${PATH}:/usr/local/sbin
export PATH=${PATH}:${HOME}/bin/depot_tools
export PATH=${PATH}:${GOPATH}/bin
export PATH=${PATH}:${GOROOT}/bin

# Custom zsh prompt
PROMPT="%(?:%{$fg_bold[green]%}%m ➜:%{$fg_bold[red]%}%m ➜)"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

# Terminal colors
${HOME}/.config/base16_color_space.sh

# Wasmer
#export WASMER_DIR="/Users/bynx/.wasmer"
#[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

#eval "$(starship init zsh)"
# Add dotfiles bin to PATH
export PATH=$PATH:/Users/bynx/opt/dotfiles/bin
