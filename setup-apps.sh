#!/bin/bash
#
# Setup a new machine!

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

# setup vim/neovim
setup_nvim() {
  mkdir ~/.config > /dev/null 2>&1
  ln -fs "$(pwd)/config/nvim" ~/.config/nvim
  when_plain print_success "nvim configured"
}
# setup zsh
setup_zsh() {
  gh completion -s zsh > ~/.zsh/completion/_gh 2>/dev/null
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting > /dev/null 2>&1
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null 2>&1
  when_plain print_success "zsh configured with"
  when_plain print_note "      completion:" "gh"
  when_plain print_note "      plugin:" "zsh-syntax-highlighting"
  when_plain print_note "      plugin:" "zsh-autosuggestions"
}

setup_osx() {
  defaults write com.apple.finder QuitMenuItem -bool YES
  defaults write com.apple.dock persistent-apps -array
  when_plain print_success "osx defaults configured"
}

setup_alacritty() {
  mkdir ~/.config > /dev/null 2>&1
  git submodule update --init --recursive > /dev/null 2>&1
  ln -fs "$(pwd)/config/alacritty" ~/.config/alacritty
  when_plain print_success "alacritty configured"
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
  setup_zsh

  if [ "$PLAIN" = 1 ]; then
    print_info "  Finished configuring apps"
  else
    step_end 0 "Finished configuring apps"
  fi
}

main

