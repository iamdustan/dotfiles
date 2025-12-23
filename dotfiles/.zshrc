# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
# https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
export ZSH_THEME="theunraveler"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"
export EDITOR="nvim"

plugins+=(git nx-completion)
source $ZSH/oh-my-zsh.sh


# plugins+=(nx-completions)
source ~/.oh-my-zsh/custom/plugins/nx-completion/nx-completion.plugin.zsh

bindkey -v
bindkey "^F" vi-cmd-mode
bindkey jj vi-cmd-mode

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.config/.aliases ]] && source ~/.config/.aliases

# load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)

# completion
autoload -U compinit
compinit

# load custom executable functions
# for function in ~/.zsh/functions/*; do
#   source $function
# done

# makes color constants available
autoload -U colors
colors

# history settings
setopt hist_ignore_all_dups inc_append_history
HISTFILE=~/.zhistory
HISTSIZE=4096
SAVEHIST=4096

# awesome cd movements from zshkit
# setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
# DIRSTACKSIZE=5

# Enable extended globbing
setopt extendedglob

# Allow [ or ] whereever you want
unsetopt nomatch

# vi mode
bindkey -v
bindkey "^F" vi-cmd-mode
bindkey jj vi-cmd-mode

# handy keybindings
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word
bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="node_modules/.bin:$PATH"
# nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# fnm
eval "$(fnm env)"

# cargo
source $HOME/.cargo/env

# ocaml
eval `opam config env`

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# pnpm
export PNPM_HOME="/Users/iamdustan/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


