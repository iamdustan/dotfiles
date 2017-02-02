
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
force_color_prompt=yes
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
'

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Detect my Pis and force a different shell to avoid
# the vim startup shell not found error
if [[ `uname` == 'Linux' ]]; then
  TERM=xterm
fi

[ -s "$HOME/.config/env" ] && \. "$HOME/.config/env"
[ -s "$HOME/.aliases" ] && \. "$HOME/.config/.aliases"

EDITOR=nvim
export EDITOR=nvim
