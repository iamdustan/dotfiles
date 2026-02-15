#!/bin/bash
#
# Setup a new machine!

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

# setup vim/neovim
setup_nvim() {
  mkdir ~/.config > /dev/null 2>&1
  ln -fs "$(pwd)/config/nvim" ~/.config/nvim
  # ln -s ~/.vimrc ~/.config/nvim/init.vim  > /dev/null 2>&1
  print_success "nvim configured"
}
# setup zsh
setup_zsh() {
  # install gh cli completion
  gh completion -s zsh > ~/.zsh/completion/_gh
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting > /dev/null 2>&1
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null 2>&1
  print_success "zsh configured with"
  print_note "      completion:" "gh"
  print_note "      plugin:" "zsh-syntax-highlighting"
  print_note "      plugin:" "zsh-autosuggestions"
}

setup_osx() {
  # support closing Finder
  defaults write com.apple.finder QuitMenuItem -bool YES
  defaults write com.apple.dock persistent-apps -array
  print_success "osx defaults configured"
}

setup_alacritty() {
  mkdir ~/.config > /dev/null 2>&1
  # mkdir ~/.config/alacritty > /dev/null 2>&1
  # pull the alacritty themes submodule
  git submodule update --init --recursive
  ln -fs "$(pwd)/config/alacritty" ~/.config/alacritty
  print_success "alacritty configured"
}

main() {
  print_info "Configuring apps"

  setup_nvim
  setup_osx
  setup_alacritty
  setup_zsh

  print_info "  Finished configuring apps"
}

main

