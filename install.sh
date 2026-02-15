#!/bin/bash
#
# Install sheesh

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

install_homebrew() {
  step_start "Installing homebrew"
  if ! cmd_exists "brew"; then
    run_with_spinner "Installing homebrew" /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    step_end $? "homebrew installed"
  else
    step_end 0 "homebrew already installed"
  fi
}

install_watchman() {
  step_start "Installing watchman"
  if ! cmd_exists "watchman"; then
    run_with_spinner "Installing watchman" brew install watchman
    step_end $? "watchman installed"
  else
    step_end 0 "watchman already installed"
  fi
}

install_fnm() {
  step_start "Installing fnm"
  if ! cmd_exists "fnm"; then
    if file_exists "$HOME/.fnm"; then
      run_with_spinner "Installing fnm" brew install Schniz/tap/fnm
      step_end $? "fnm installed"
    else
      step_end 0 "fnm already installed"
    fi
  else
    step_end 0 "fnm already installed"
  fi
}

install_node() {
  step_start "Installing node"
  if ! cmd_exists "node"; then
    run_with_spinner "Installing node" fnm install v20
    step_end $? "node v20.x.x installed"
  else
    step_end 0 "node v20.x.x already installed"
  fi
}

install_ocaml() {
  # TODO install these independently
  step_start "Installing ocaml/opam"
  if ! cmd_exists "opam"; then
    run_with_spinner "Installing ocaml/opam" bash -c "brew install ocaml && brew install opam"
    step_end $? "ocaml and opam installed"
  else
    step_end 0 "ocaml and opam already installed"
  fi
}

install_gh() {
  step_start "Installing gh"
  if ! cmd_exists "gh"; then
    run_with_spinner "Installing gh" brew install gh
    step_end $? "gh installed"
  else
    step_end 0 "gh already installed"
  fi
}

install_gitdelta() {
  step_start "Installing git-delta"
  if ! brew list git-delta >/dev/null 2>&1; then
    run_with_spinner "Installing git-delta" brew install git-delta
    step_end $? "git-delta installed"
  else
    step_end 0 "git-delta already installed"
  fi
}


install_rustup() {
  step_start "Installing rustup/cargo"
  if ! cmd_exists "cargo"; then
    run_with_spinner "Installing rustup/cargo" bash -c "curl https://sh.rustup.rs -sSf | sh"
    step_end $? "cargo installed"
  else
    step_end 0 "cargo already installed"
  fi
}

# OpenGL terminal emulator
# https://github.com/alacritty/alacritty
install_alacritty() {
  step_start "Installing alacritty"
  if ! brew cask info alacritty &>/dev/null; then
    run_with_spinner "Installing alacritty" bash -c "brew cask install alacritty && sudo tic -xe alacritty,alacritty-direct extra/alacritty.info"
    step_end $? "alacritty installed"
  else
    step_end 0 "alacritty already installed"
  fi
}

# vim for the modern era
# https://neovim.io/
install_neovim() {
  step_start "Installing neovim"
  if ! cmd_exists "nvim"; then
    run_with_spinner "Installing neovim" brew install neovim/neovim/neovim
    step_end $? "neovim (nvim) installed"
  else
    step_end 0 "neovim already installed"
  fi
}

# terminal multiplexer
# https://github.com/tmux/tmux/wiki
install_tmux() {
  step_start "Installing tmux"
  if ! cmd_exists "tmux"; then
    run_with_spinner "Installing tmux" brew install tmux
    step_end $? "tmux installed"
  else
    step_end 0 "tmux already installed"
  fi
}

# zsh / ohmyzsh is an interactive shell
# https://ohmyz.sh/
install_zsh() {
  step_start "Installing zsh/oh-my-zsh"
  if file_exists "$HOME/.zshrc"; then
    run_with_spinner "Installing zsh/oh-my-zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    step_end $? "zsh installed"
  else
    step_end 0 "zsh already installed"
  fi
}

# fzf is a general-purpose command-line fuzzy finder.
# https://github.com/junegunn/fzf
install_fzf() {
  step_start "Installing fzf"
  if ! cmd_exists "fzf"; then
    run_with_spinner "Installing fzf" brew install fzf
    step_end $? "fzf installed"
  else
    step_end 0 "fzf already installed"
  fi
}

install_ag() {
  step_start "Installing the_silver_searcher (ag)"
  if ! cmd_exists "ag"; then
    run_with_spinner "Installing the_silver_searcher (ag)" brew install the_silver_searcher
    step_end $? "the_silver_searcher (ag) installed"
  else
    step_end 0 "the_silver_searcher (ag) already installed"
  fi
}

install_ripgrep() {
  step_start "Installing ripgrep"
  if ! cmd_exists "rg"; then
    run_with_spinner "Installing ripgrep" brew install ripgrep
    step_end $? "ripgrep (rg) installed"
  else
    step_end 0 "ripgrep (rg) already installed"
  fi
}

# A simple, fast and user-friendly alternative to 'find'
# https://github.com/sharkdp/fd
install_fd() {
  step_start "Installing fd"
  if ! cmd_exists "fd"; then
    run_with_spinner "Installing fd" brew install fd
    step_end $? "fd installed"
  else
    step_end 0 "fd already installed"
  fi
}

install_amethyst() {
  step_start "Installing amethyst"
  if ! brew info amethyst &>/dev/null; then
    run_with_spinner "Installing amethyst" brew install amethyst
    step_end $? "amethyst installed"
  else
    step_end 0 "amethyst already installed"
  fi
}

install_lazygit() {
  step_start "Installing lazygit"
  if ! brew info lazygit &>/dev/null; then
    run_with_spinner "Installing lazygit" bash -c "brew install jesseduffield/lazygit/lazygit && brew install lazygit"
    step_end $? "lazygit installed"
  else
    step_end 0 "lazygit already installed"
  fi
}

install_fonts() {
  step_start "Installing Caskaydia nerdfonts"
  run_with_spinner "Installing Caskaydia nerdfonts" bash -c "brew install homebrew/cask/font-caskaydia-cove-nerd-font && brew install homebrew/cask/font-caskaydia-mono-nerd-font"
  step_end $? "Caskaydia Cove and Mono nerdfonts installed"
}

install_chatgptcli() {
  step_start "Installing chatgpt CLI"
  if ! brew info chatgpt &>/dev/null; then
    run_with_spinner "Installing chatgpt CLI" brew install j178/tap/chatgpt
    step_end $? "chatgpt CLI installed"
  else
    step_end 0 "chatgpt CLI already installed"
  fi
  if [ -f "$HOME/.zshrc.local" ] && ! grep -q OPENAI_API_KEY "$HOME/.zshrc.local" 2>/dev/null; then
    print_info "     Create chatgpt API key at https://platform.openai.com/account/api-keys"
    print_info "     # In ~/.zshrc.local"
    print_info "     export OPENAI_API_KEY=xxx"
  fi
}


install_grc() {
  step_start "Installing grc"
  if ! brew info grc &>/dev/null; then
    run_with_spinner "Installing grc" brew install grc
    step_end $? "grc installed"
  else
    step_end 0 "grc already installed"
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
install_gitdelta
install_lazygit
install_fonts
install_neovim
install_tmux
install_ripgrep
install_fzf # fuzzy finder
install_fd # better `find`
install_zsh
install_grc
# install_chatgptcli
# install_alacritty # I usually building alacritty from source weekly.

# programming languages
install_fnm
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

