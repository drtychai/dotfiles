export ZSH_CONFIG_DIR=${HOME}/.config/zsh
source "${ZSH_CONFIG_DIR}/history.zsh"       # term-based history
source "${ZSH_CONFIG_DIR}/completion.zsh"    # tab-completion
source "${ZSH_CONFIG_DIR}/key-bindings.zsh"  # conditional history (e.g., git <UP_KEY>)

export STARSHIP_CONFIG=${HOME}/.config/starship.toml

export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec
export GOOS=`uname | awk '{print tolower($0)}'`

# Install rust, if missing
[[ ! -e `which cargo` ]] && curl --proto "=https" --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y

# Set up aliases
[ -f ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh
[ -f ${HOME}/.bash_aliases ] && source ${HOME}/.bash_aliases
[ -f ${HOME}/.cargo/env ] && source ${HOME}/.cargo/env

# Install starship, if missing
[[ ! -e `which starship` ]] && cargo install starship

# Add dotfiles bin to PATH
export PATH=${PATH}:/usr/local/sbin                   
export PATH=${PATH}:${HOME}/bin:${HOME}/bin/depot_tools
export PATH=${PATH}:${HOME}/opt/sources/dotfiles/bin
export PATH=${PATH}:${GOPATH}/bin:${GOROOT}/bin

# Terminal colors (runs base16 script)
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
eval "$(starship init zsh)"
