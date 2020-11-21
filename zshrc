# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

# oh-mu-zsh, rust, and go environment vars
source $ZSH/oh-my-zsh.sh

export GOOS=`uname | awk '{print tolower($0)}'`
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
export PATH=$PATH:/Users/bynx/opt/dotfiles/bin

# Custom zsh prompt
PROMPT="%(?:%{$fg_bold[green]%}%m ➜:%{$fg_bold[red]%}%m ➜)"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

# Terminal colors
${HOME}/.config/base16_color_space.sh

# Wasmer
#export WASMER_DIR="/Users/bynx/.wasmer"
#[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

# Add zoxide to our shell
# * Usage (https://github.com/ajeetdsouza/zoxide#examples):
#     z foo       # cd to highest ranked directory matching foo
#     z foo bar   # cd to highest ranked directory matching foo and bar
#     z foo/      # can also cd into actual directories
#     zi foo      # cd with interactive selection using fzf
#     zq foo      # echo the best match, don't cd
#     za /foo     # add /foo to the database
#     zr /foo     # remove /foo from the database
eval "$(zoxide init posix --hook prompt)"

#eval "$(starship init zsh)"

