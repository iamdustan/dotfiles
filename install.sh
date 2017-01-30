#!/bin/bash
#
# Install sheesh

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

cmd_exists() {
    [ -x "$(command -v "$1")" ] \
        && return 0 \
        || return 1
}

install_homebrew() {
  if ! cmd_exists "brew"
  then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

install_nvm() {
  if ! cmd_exists "nvm"
  then
    if [ ! -d ".nvm" ]
    then
      # curl -o- https://raw.githubusercontent.com/creationix/nvm/v1.33.0/install.sh | bash
      print_info "FIXME: only install nvm when it doesn't actually exist"
    fi
  fi
}

install_rustup() {
  if ! cmd_exists "rustup"
  then
    curl https://sh.rustup.rs -sSf | sh
  fi
}

install_neovim() {
  if ! cmd_exists "nvim"
  then
    brew install neovim/neovim/neovim
  fi
}

install_hub() {
  if ! cmd_exists "hub"
  then
    brew install hub
  fi
}

install_tmux() {
  if ! cmd_exists "tmux"
  then
    brew install tmux
  fi
}

install_zsh() {
  print_info "FIXME: only install zsh when it doesn't actually exist"
  # TODO: Make this idempotent
  # sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

install_ag() {
  if ! cmd_exists "ag"
  then
    brew install the_silver_searcher
  fi
}

print_info "Installing basic applications"

install_homebrew
install_nvm
install_rustup
install_neovim
install_hub
install_tmux
install_zsh
install_ag

