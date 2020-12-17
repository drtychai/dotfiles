# Terminal
export LANG=en_US.UTF-8
[[ "${OSTYPE}" == "linux-gnu" ]] && export TERM=screen-256color
[[ "${OSTYPE}" == "darwin.*" ]] && export TERM=xterm-256color 

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
#alias ....="cd ../../.."
#alias .....="cd ../../../.."
#alias ......="cd ../../../../.."

# ls alias
alias l='ls -l'
alias ll='ls -la'

# Suppress the copyright info when start gdb
alias gdb='gdb -q'

# fast clear
alias c='clear'

# vim
alias vi='vim'

# quick notes
alias nt="echo \[`date '+%Y-%m-%d %H:%M:%S'`\]  $@ >> ${HOME}/.notes.md"
