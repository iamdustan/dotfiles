#!/bin/bash
#
# Setup a new machine!


print_error() {
    # Print output in red
    printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
    # Print output in purple
    printf "\n\e[0;35m $1\e[0m\n\n"
}

print_question() {
    # Print output in yellow
    printf "\e[0;33m  [?] $1\e[0m"
}

print_result() {
    [ $1 -eq 0 ] \
        && print_success "$2" \
        || print_error "$2"

    [ "$3" == "true" ] && [ $1 -ne 0 ] \
        && exit
}

print_success() {
    # Print output in green
    printf "\e[0;32m  [✔] $1\e[0m\n"
}


# setup vim/neovim
setup_nvim() {
  mkdir ~/.config  > /dev/null 2>&1
  ln -fs $(pwd)/config/nvim ~/.config/nvim
  # ln -s ~/.vimrc ~/.config/nvim/init.vim  > /dev/null 2>&1
  print_success "nvim configured"
}
# setup zsh
setup_zsh() {
  # install gh cli completion
  gh completion -s zsh > ~/.zsh/completion/_gh
  print_success "zsh configured with completions: gh"
}

setup_osx() {
  # support closing Finder
  defaults write com.apple.finder QuitMenuItem -bool YES
  # clear out the Dock
  defaults write com.apple.dock persistent-apps -array
  print_success "osx defaults configured"
}

setup_alacritty() {
  mkdir ~/.config > /dev/null 2>&1
  # mkdir ~/.config/alacritty > /dev/null 2>&1
  ln -fs $(pwd)/config/alacritty ~/.config/alacritty
  print_success "alacritty configured"
}

main() {
  print_info "Configuring apps"

  setup_nvim
  setup_osx
  setup_alacritty

  print_info "  Finished configuring apps"
}

main

