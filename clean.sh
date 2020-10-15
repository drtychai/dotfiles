#!/bin/sh

# List of symlinks to remove
FILES="${HOME}/.bash_aliases
${HOME}/.bin
${HOME}/.iterm2
${HOME}/.karabiner.json
${HOME}/.README.md
${HOME}/.tmux
${HOME}/.tmux.conf
${HOME}/.vim
${HOME}/.vimrc
${HOME}/.weechat"

for f in $FILES; do
    rm -rfi $f
done
