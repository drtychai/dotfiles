########## Dotfiles ##########
function append_path() {
    local paths=( "${@}" )

    # If path substring is not in current env PATH, then append
    for p in "${paths[@]}"; do
        [[ ! "${PATH}" == *":${p}:"* ]] && export PATH="${p}:${PATH}"
    done
}

export ZSH="${HOME}/.oh-my-zsh"
source "${ZSH}/oh-my-zsh.sh"

#export ZSH="${HOME}/.config/zsh"
#source "${ZSH}/history.zsh"       # term-based history
#source "${ZSH}/completion.zsh"    # tab-completion
#source "${ZSH}/key-bindings.zsh"  # conditional history (e.g., git <UP_KEY>)

export GOPATH="${HOME}/go"
export GOROOT="/usr/local/opt/go/libexec"
export GOOS="`uname | awk '{print tolower($0)}'`"

# Set up shell aliases
[ -f "${HOME}/.bash_aliases" ]     &&  source "${HOME}/.bash_aliases"
[ -f "${HOME}/.cargo/env" ]        &&  source "${HOME}/.cargo/env"
[ -f "${HOME}/.fzf.zsh" ]          &&  source "${HOME}/.fzf.zsh"
#[ -s "${HOME}/.wasmer/wasmer.sh" ] &&  source "${HOME}/.wasmer/wasmer.sh"

# Install rust, if missing
[[ ! -e `which cargo` ]] \
    && curl --proto "=https" --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y

# Install starship, if missing
[[ ! -e `which starship` ]] \
    && cargo install -j`nproc` starship

export STARSHIP_CONFIG="${HOME}/.config/starship.toml"

# Prep shell env
declare -a LOCAL_PATHS=(
    "/usr/local/bin"
    "/usr/local/sbin"
    "/opt/depot_tools"
    "${HOME}/opt/sources/dotfiles/bin"
    "${GOPATH}/bin"
    "${GOROOT}/bin"
    #"${HOME}/.wasmtime/bin"
) && append_path ${LOCAL_PATHS}

# Terminal colors (runs base16 script)
${HOME}/.config/base16_color_space.sh

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
