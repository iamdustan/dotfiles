#!/bin/bash
#
# Install sheesh

print_error() {
    # Print output in red
    printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
    # Print output in purple
    printf "\e[0;35m $1\e[0m\n"
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

file_exists() {
    [ -d $1 ] \
        && return 0 \
        || return 1
}

install_homebrew() {
  if ! cmd_exists "brew"
  then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    print_success "homebrew installed"
  else
    print_success "homebrew already installed"
  fi
}

install_watchman() {
  if ! cmd_exists "watchman"
  then
    brew install watchman
    print_success "watchman installed"
  else
    print_success "watchman already installed"
  fi
}

install_nvm() {
  if ! cmd_exists "nvm"
  then
    if file_exists "$HOME/.nvm"
    then
      curl -o- https://raw.githubusercontent.com/creationix/nvm/v1.33.0/install.sh | bash
      print_success "nvm installed"
    else
      print_success "nvm already installed"
    fi
  fi
}

install_fnm() {
  if ! cmd_exists "fnm"
  then
    if file_exists "$HOME/.fnm"
    then
      brew install Schniz/tap/fnm
      print_success "fnm installed"
    else
      print_success "fnm already installed"
    fi
  fi
}

install_node() {
  if ! cmd_exists "node"
  then
    fnm install v20 &>/dev/null
    print_success "node v20.x.x installed"
  else
    print_success "node v20.x.x already installed"
  fi
}

install_ocaml() {
  # TODO install these independently
  if ! cmd_exists "opam"
  then
    brew install ocaml &>/dev/null
    print_success "ocaml installed"

    brew install opam &>/dev/null
    print_success "opam installed"
  else
    print_success "ocaml already installed"
    print_success "opam already installed"
  fi

}

install_gh() {
  if ! cmd_exists "gh"
  then
    brew install gh
    print_success "gh installed"
  else
    print_success "gh already installed"
  fi
}

install_rustup() {
  if ! cmd_exists "cargo"
  then
    curl https://sh.rustup.rs -sSf | sh
    print_success "cargo installed"
  else
    print_success "cargo already installed"
  fi
}

# OpenGL terminal emulator
# https://github.com/alacritty/alacritty
install_alacritty() {
  if ! brew cask info alacritty &>/dev/null;
  then
    brew cask install alacritty
    sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
    print_success "alacritty installed"
  else
    print_success "alacritty already installed"
  fi
}

# vim for the modern era
# https://neovim.io/
install_neovim() {
  if ! cmd_exists "nvim"
  then
    brew install neovim/neovim/neovim
    print_success "neovim (nvim) installed"
  else
    print_success "neovim already installed"
  fi
}

# github maintained git util library
# https://github.com/github/hub
install_hub() {
  if ! cmd_exists "hub"
  then
    brew install hub
    print_success "hub installed"
  fi
}

# terminal multiplexer
# https://github.com/tmux/tmux/wiki
install_tmux() {
  if ! cmd_exists "tmux"
  then
    brew install tmux
    print_success "tmux installed"
  else
    print_success "tmux already installed"
  fi
}

# zsh / ohmyzsh is an interactive shell
# https://ohmyz.sh/
install_zsh() {
  if file_exists $HOME/.zshrc
  then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print_success "zsh installed"
  else
    print_success "zsh already installed"
  fi
}

# fzf is a general-purpose command-line fuzzy finder.
# https://github.com/junegunn/fzf
install_fzf() {
  if ! cmd_exists "fzf"
  then
    brew install fzf
    print_success "fzf (ag) installed"
  else
    print_success "fzf (ag) already installed"
  fi
}

install_ag() {
  if ! cmd_exists "ag"
  then
    brew install the_silver_searcher
    print_success "the_silver_searcher (ag) installed"
  else
    print_success "the_silver_searcher (ag) already installed"
  fi
}

install_ripgrep() {
  if ! cmd_exists "rg"
  then
    brew install  ripgrep
    print_success "ripgrep (rg) installed"
  else
    print_success "ripgrep (rg) already installed"
  fi
}

# A simple, fast and user-friendly alternative to 'find' 
# https://github.com/sharkdp/fd
install_fd() {
  if ! cmd_exists "fd"
  then
    brew install fd
    print_success "fd installed"
  else
    print_success "fd already installed"
  fi
}

install_amethyst() {
  if ! brew info amethyst &>/dev/null;
  then
    brew install amethyst
    print_success "amethyst installed"
  else
    print_success "amethyst already installed"
  fi
}

install_lazygit() {
  if ! brew info lazygit &>/dev/null;
  then
    brew install jesseduffield/lazygit/lazygit
    brew install lazygit
    print_success "lazygit installed"
  else
    print_success "lazygit already installed"
  fi
}

install_fonts() {
  brew install homebrew/cask/font-caskaydia-cove-nerd-font
  brew install homebrew/cask/font-caskaydia-mono-nerd-font

  # brew install font-caskaydia-cove-nerd-font
  # brew install font-caskaydia-mono-nerd-font
  print_success "Caskaydia Cove and Mono nerdfonts installed"
}

install_chatgptcli() {
  if ! brew info chatgpt &>/dev/null;
  then
    # https://github.com/j178/chatgpt
    brew install j178/tap/chatgpt
    print_success "lazygit installed"
  else
    print_success "lazygit already installed"
  fi
  # Remind to add API key if necessary
  if grep -q OPEN_API_KEY "$HOME/.zshrc.local"; then
    print_info "     Create chatgpt API key at https://platform.openai.com/account/api-keys"
    print_info "     # In ~/.zshrc.local"
    print_info "     export OPENAI_API_KEY=xxx"
  fi
}

upgrade_casks() {
    print_info "upgrading casks"
    brew cask upgrade
}

print_info "Installing base developer applications"


# mac tools
install_homebrew
install_watchman

# dev tools
install_gh
install_lazygit
install_fonts
install_neovim
install_tmux
install_ripgrep
install_fzf # fuzzy finder
install_fd # better `find`
install_zsh
install_chatgptcli
# install_alacritty # I usually building alacritty from source weekly.

# programming languages
install_fnm # fnm > nvm
install_rustup
install_node


# upgrade_casks
# dustandeprecated: things I don’t use anymore
# install_ocaml # reasonml had a day
# install_ag # replaced by ripgrep
# install_amethyst # I don’t like this window manager
# install_hub

print_info "Remember to build alacritty from source"
print_info "  git clone git@github.com:alacritty/alacritty.git && cd alacritty && make app"
print_info "  Finished installing base applications"
# TODO: set up a cronjob on your computer for this

