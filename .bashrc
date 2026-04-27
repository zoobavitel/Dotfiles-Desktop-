#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"
export PATH="$HOME/Applications:$PATH"

# Created by `pipx` on 2026-04-21 17:54:50
export PATH="$PATH:/home/z/.local/bin"
alias dot='git --git-dir=/home/z/git/Dotfiles-Desktop-/.git --work-tree=/home/z'
