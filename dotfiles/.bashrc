export NODE_ENV='development'
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
[ -s "$HOME/.config/.aliases" ] && \. "$HOME/.config/.aliases"

EDITOR=nvim
export EDITOR=nvim

# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"

# for eslint_d
export ESLINT_USE_FLAT_CONFIG=true
