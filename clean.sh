#!/bin/sh

# List of symlinks to remove
FILES="${HOME}/.bash_aliases
${HOME}/.tmux
${HOME}/.tmux.conf
${HOME}/.vim
${HOME}/.vimrc"

# Delete all dotfiles-related directories
for f in $FILES; do
    if [[ "${f}" == *".tmux" ]];then
        rm -rf ${f}
    else
        rm -rfi $f
    fi
done
