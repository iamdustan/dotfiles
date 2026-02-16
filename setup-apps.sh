#!/bin/bash
#
# Setup a new machine!

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

# setup vim/neovim
setup_nvim() {
  mkdir -p ~/.config 2>/dev/null
  ln -fs "$SETUP_ROOT/config/nvim" ~/.config/nvim
  when_plain print_success "nvim configured"
}
# setup zsh
setup_zsh() {
  mkdir -p ~/.zsh/completion
  local -a completions=()
  gh completion -s zsh > ~/.zsh/completion/_gh 2>/dev/null && completions+=(gh)
  if [ -d "$SETUP_ROOT/dotfiles/.zsh/completion" ]; then
    for f in "$SETUP_ROOT/dotfiles/.zsh/completion"/_*; do
      completions+=("$(basename "$f" | sed 's/^_//')")
      [ -e "$f" ] || continue
      ln -sf "$f" ~/.zsh/completion/
    done
  fi
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [ -d "$custom/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting" > /dev/null 2>&1
  [ -d "$custom/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$custom/plugins/zsh-autosuggestions" > /dev/null 2>&1
  when_plain print_success "zsh configured with"
  print_note ""
  [ ${#completions[@]} -gt 0 ] && print_note "      completion:" "$(IFS=', '; echo "${completions[*]}")"
  print_note "      plugin:" "zsh-syntax-highlighting"
  print_note "      plugin:" "zsh-autosuggestions"
}

setup_osx() {
  [ "$(uname)" = "Darwin" ] || return 0
  defaults write com.apple.finder QuitMenuItem -bool YES
  defaults write com.apple.dock persistent-apps -array
  when_plain print_success "osx defaults configured"
}

setup_alacritty() {
  mkdir -p ~/.config 2>/dev/null
  (cd "$SETUP_ROOT" && git submodule update --init --recursive config/alacritty 2>/dev/null) || true
  ln -fs "$SETUP_ROOT/config/alacritty" ~/.config/alacritty
  when_plain print_success "alacritty configured"
}

setup_conduit() {
  mkdir -p ~/.conduit 2>/dev/null
  local default_agent="claude"
  if [ -f "$SETUP_ROOT/config/conduit/.default_agent" ]; then
    read -r default_agent < "$SETUP_ROOT/config/conduit/.default_agent" || true
    case "$default_agent" in
      claude|codex|gemini) ;;
      *) default_agent="gemini" ;;
    esac
  fi
  sed "s/^default_agent = .*/default_agent = \"$default_agent\"/" \
    "$SETUP_ROOT/config/conduit/config.toml" > ~/.conduit/config.toml
  when_plain print_success "conduit configured (default_agent=$default_agent)"
}

main() {
  if [ "$PLAIN" = 1 ]; then
    print_info "Configuring apps"
  else
    step_start "Configuring apps"
  fi

  setup_nvim
  setup_osx
  setup_alacritty
  setup_conduit
  setup_zsh

  if [ "$PLAIN" = 1 ]; then
    print_info "  Finished configuring apps"
  else
    step_end 0 "Finished configuring apps"
  fi
}

main

