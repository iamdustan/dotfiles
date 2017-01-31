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
# Plug
setup_nvim() {
  # this is a bit of a hack. It’s still taking a vim-first approach and
  # configuring normal vim, then symlinking
  if [ ! -f $HOME/.vim/autoload/plug.vim ]
  then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  vim +PlugInstall +qall
  mkdir ~/.config  > /dev/null 2>&1
  mkdir ~/.config/nvim  > /dev/null 2>&1
  ln -s ~/.vim ~/.config/nvim  > /dev/null 2>&1
  ln -s ~/.vimrc ~/.config/nvim/init.vim  > /dev/null 2>&1
  print_success "nvim configured"
}


main() {
  print_info "Configuring apps"

  setup_nvim

  print_info "  Finished configuring apps"
}

main

