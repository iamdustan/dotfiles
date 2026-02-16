#!/bin/bash
#
# Install sheesh

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

# Defaults for optional steps when not -i. Change here to update behavior everywhere.
DEFAULT_INSTALL_LAZYGIT="yes"
DEFAULT_INSTALL_FD="yes"
DEFAULT_INSTALL_GRC="no"
DEFAULT_INSTALL_RUSTUP="yes"
DEFAULT_INSTALL_CHATGPTCLI="no"
DEFAULT_INSTALL_ALACRITTY="yes"
DEFAULT_INSTALL_OCAML="no"
DEFAULT_INSTALL_AG="no"
DEFAULT_INSTALL_AMETHYST="no"

NODE_DEFAULT_VERSION=24

install_homebrew() {
  step_start "Installing homebrew"
  if ! cmd_exists "brew"; then
    run_with_spinner "Installing homebrew" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
  local version="$NODE_DEFAULT_VERSION"

  if cmd_exists "node"; then
    local current_major
    current_major=$(node -v 2>/dev/null | sed 's/^v//; s/\..*//')
    if [ -n "$current_major" ] && [ "$current_major" = "$NODE_DEFAULT_VERSION" ]; then
      step_start "Installing node"
      step_end 0 "node v$current_major already installed"
      return 0
    fi
  fi

  if [ "$INTERACTIVE" = 1 ]; then
    local node_lts="" node_current=""
    local idx_json
    idx_json=$(curl -sL https://nodejs.org/dist/index.json 2>/dev/null)
    if [ -n "$idx_json" ] && cmd_exists "jq"; then
      node_lts=$(printf '%s' "$idx_json" | jq -r '[.[] | select(.lts) | .version] | first // empty' 2>/dev/null)
      node_current=$(printf '%s' "$idx_json" | jq -r '[.[] | select((.version | split(".")[0] | ltrimstr("v") | tonumber) % 2 == 0) | .version] | first // empty' 2>/dev/null)
    fi

    if [ -n "$node_lts" ] && [ -n "$node_current" ]; then
      print_question "Node version to install? (Latest LTS: $node_lts, Latest current: $node_current) [$NODE_DEFAULT_VERSION] "
    else
      print_question "Node version to install? [$NODE_DEFAULT_VERSION] "
    fi
    read -r
    if [ -n "${REPLY:-}" ]; then
      version="${REPLY#v}"
      version="${version%%[^0-9]*}"
      [ -z "$version" ] && version="$NODE_DEFAULT_VERSION"
      if [ "$version" != "$NODE_DEFAULT_VERSION" ]; then
        sed -i.bak "s/^NODE_DEFAULT_VERSION=.*/NODE_DEFAULT_VERSION=$version/" "$SETUP_ROOT/install.sh" 2>/dev/null && rm -f "$SETUP_ROOT/install.sh.bak"
      fi
    fi
  fi

  step_start "Installing node"
  if ! cmd_exists "node"; then
    run_with_spinner "Installing node" fnm install "v$version"
    step_end $? "node v$version installed"
  else
    step_end 0 "node v$version already installed"
  fi
}

# OCaml + opam: OCaml toolchain.
install_ocaml() {
  if cmd_exists "opam"; then
    step_start "Installing ocaml/opam"
    step_end 0 "ocaml and opam already installed"
    return 0
  fi
  confirm_optional "Install ocaml/opam?" "$DEFAULT_INSTALL_OCAML" || return 0
  # TODO install these independently
  step_start "Installing ocaml/opam"
  run_with_spinner "Installing ocaml/opam" bash -c "brew install ocaml && brew install opam"
  step_end $? "ocaml and opam installed"
}

# gh: GitHub CLI.
install_gh() {
  step_start "Installing gh"
  if ! cmd_exists "gh"; then
    run_with_spinner "Installing gh" brew install gh
    step_end $? "gh installed"
  else
    step_end 0 "gh already installed"
  fi
}

# git-delta: Git diff pager with syntax highlighting.
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
  if cmd_exists "cargo"; then
    step_start "Installing rustup/cargo"
    step_end 0 "cargo already installed"
    return 0
  fi
  confirm_optional "Install rustup/cargo?" "$DEFAULT_INSTALL_RUSTUP" || return 0
  step_start "Installing rustup/cargo"
  run_with_spinner "Installing rustup/cargo" bash -c "curl https://sh.rustup.rs -sSf | sh"
  step_end $? "cargo installed"
}

# OpenGL terminal emulator
# https://github.com/alacritty/alacritty
install_alacritty() {
  local parent="$(dirname "$SETUP_ROOT")"
  local alacritty_dir="$parent/alacritty"
  local app_bundle="$alacritty_dir/target/release/osx/Alacritty.app"

  if [ -d /Applications/Alacritty.app ] || cmd_exists "alacritty"; then
    step_start "Installing alacritty"
    step_end 0 "alacritty already installed"
    return 0
  fi
  if [ -d "$alacritty_dir" ] && [ -d "$app_bundle" ]; then
    step_start "Installing alacritty"
    step_end 0 "alacritty already installed (from source)"
    return 0
  fi
  confirm_optional "Install alacritty from source? (gh clone + make app)" "$DEFAULT_INSTALL_ALACRITTY" || return 0
  step_start "Installing alacritty"
  if [ ! -d "$alacritty_dir" ]; then
    run_with_spinner "Cloning alacritty" bash -c "cd \"$parent\" && gh repo clone alacritty/alacritty"
    local err=$?
    [ $err -ne 0 ] && step_end 1 "alacritty clone failed" && return 1
  fi
  run_with_spinner "Building alacritty" bash -c "cd \"$alacritty_dir\" && make app"
  err=$?
  [ $err -ne 0 ] && step_end 1 "alacritty build failed" && return 1
  cp -r "$app_bundle" /Applications/ 2>/dev/null || true
  step_end 0 "alacritty installed from source"
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
  if cmd_exists "ag"; then
    step_start "Installing the_silver_searcher (ag)"
    step_end 0 "the_silver_searcher (ag) already installed"
    return 0
  fi
  confirm_optional "Install the_silver_searcher (ag)? (largely superseded by ripgrep)" "$DEFAULT_INSTALL_AG" || return 0
  step_start "Installing the_silver_searcher (ag)"
  run_with_spinner "Installing the_silver_searcher (ag)" brew install the_silver_searcher
  step_end $? "the_silver_searcher (ag) installed"
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

# jq: JSON processor for CLI.
install_jq() {
  step_start "Installing jq"
  if ! cmd_exists "jq"; then
    run_with_spinner "Installing jq" brew install jq
    step_end $? "jq installed"
  else
    step_end 0 "jq already installed"
  fi
}

# fd: fast find alternative.
install_fd() {
  if cmd_exists "fd"; then
    step_start "Installing fd"
    step_end 0 "fd already installed"
    return 0
  fi
  confirm_optional "Install fd? (fast find alternative)" "$DEFAULT_INSTALL_FD" || return 0
  step_start "Installing fd"
  run_with_spinner "Installing fd" brew install fd
  step_end $? "fd installed"
}

# Amethyst: tiling window manager for macOS.
install_amethyst() {
  if brew info amethyst &>/dev/null; then
    step_start "Installing amethyst"
    step_end 0 "amethyst already installed"
    return 0
  fi
  confirm_optional "Install amethyst? (tiling window manager)" "$DEFAULT_INSTALL_AMETHYST" || return 0
  step_start "Installing amethyst"
  run_with_spinner "Installing amethyst" brew install amethyst
  step_end $? "amethyst installed"
}

# lazygit: TUI for git.
install_lazygit() {
  if brew info lazygit &>/dev/null; then
    step_start "Installing lazygit"
    step_end 0 "lazygit already installed"
    return 0
  fi
  confirm_optional "Install lazygit? (TUI for git, also from nvim)" "$DEFAULT_INSTALL_LAZYGIT" || return 0
  step_start "Installing lazygit"
  run_with_spinner "Installing lazygit" bash -c "brew install jesseduffield/lazygit/lazygit && brew install lazygit"
  step_end $? "lazygit installed"
}

# Caskaydia Nerd Fonts. 2>&1 | cat so brew progress doesn't leak \r noise.
install_fonts() {
  step_start "Installing Caskaydia nerdfonts"
  run_with_spinner "Installing Caskaydia nerdfonts" bash -c "brew install --cask font-caskaydia-cove-nerd-font font-caskaydia-mono-nerd-font 2>&1 | cat"
  step_end $? "Caskaydia Cove and Mono nerdfonts installed"
}

# ChatGPT CLI. Prompts to add OPENAI_API_KEY to .zshrc.local if missing.
install_chatgptcli() {
  if brew info chatgpt &>/dev/null; then
    step_start "Installing chatgpt CLI"
    step_end 0 "chatgpt CLI already installed"
    return 0
  fi
  confirm_optional "Install ChatGPT CLI?" "$DEFAULT_INSTALL_CHATGPTCLI" || return 0
  step_start "Installing chatgpt CLI"
  run_with_spinner "Installing chatgpt CLI" brew install j178/tap/chatgpt
  step_end $? "chatgpt CLI installed"
  if [ -f "$HOME/.zshrc.local" ] && ! grep -q OPENAI_API_KEY "$HOME/.zshrc.local" 2>/dev/null; then
    print_info "     Create chatgpt API key at https://platform.openai.com/account/api-keys"
    print_info "     # In ~/.zshrc.local"
    print_info "     export OPENAI_API_KEY=xxx"
  fi
}


# grc: generic colouriser.
install_grc() {
  if brew info grc &>/dev/null; then
    step_start "Installing grc"
    step_end 0 "grc already installed"
    return 0
  fi
  confirm_optional "Install grc? (generic colouriser)" "$DEFAULT_INSTALL_GRC" || return 0
  step_start "Installing grc"
  run_with_spinner "Installing grc" brew install grc
  step_end $? "grc installed"
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
if [ "$INTERACTIVE" = 1 ] && cmd_exists "gh"; then
  if ! gh auth status &>/dev/null; then
    print_info "Authenticate with GitHub"
    gh auth login
  fi
fi
install_gitdelta
install_lazygit
install_fonts
install_neovim
install_tmux
install_ripgrep
install_jq
install_fzf
install_fd
install_zsh
install_grc
install_chatgptcli
install_alacritty
install_ocaml
install_ag
install_amethyst

# programming languages
install_fnm
install_rustup
install_node

print_info "  Finished installing base applications"
# TODO: set up a cronjob on your computer for this

