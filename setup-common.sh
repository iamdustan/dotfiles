#!/bin/bash
#
# Shared flags and helpers for setup scripts.
# Source with: source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-common.sh" "$@"
#

# Parse -i/--interactive, -v/--verbose, -p/--plain from "$@" (no shift so caller's "$@" is unchanged)
# Not exported so we don't override VERBOSE/INTERACTIVE used by other tools.
INTERACTIVE=0
VERBOSE=0
PLAIN=0
for _arg in "$@"; do
  case "$_arg" in
    -i|--interactive) INTERACTIVE=1 ;;
    -v|--verbose)     VERBOSE=1 ;;
    -p|--plain)        PLAIN=1 ;;
  esac
done

# --- Print helpers ---

print_error() {
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
  printf "\e[0;35m $1\e[0m\n"
}

print_question() {
  printf "\e[0;33m  [?] $1\e[0m"
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"
  [ "${3:-}" = "true" ] && [ $1 -ne 0 ] && exit
}

print_success() {
  printf "\e[0;32m  [✔] $1\e[0m\n"
}

print_note() {
  printf "\\e[90m $1 \\e[37m$2\e[0m\n"
}

# --- Shared helpers ---

cmd_exists() {
  [ -x "$(command -v "$1")" ] && return 0 || return 1
}

file_exists() {
  [ -d "$1" ] && return 0 || return 1
}

# Used by setup-dotfiles
answer_is_yes() {
  [[ "${REPLY:-}" =~ ^[Yy]$ ]] && return 0 || return 1
}

ask() {
  print_question "$1"
  read -r
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -n 1 -r
  printf "\n"
}

ask_for_sudo() {
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &> /dev/null &
}

execute() {
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}

get_answer() {
  printf "%s" "${REPLY:-}"
}

get_os() {
  declare -r OS_NAME="$(uname -s)"
  local os=""
  if [ "$OS_NAME" = "Darwin" ]; then
    os="osx"
  elif [ "$OS_NAME" = "Linux" ] && [ -e "/etc/lsb-release" ]; then
    os="ubuntu"
  fi
  printf "%s" "$os"
}

is_git_repository() {
  [ "$(git rev-parse &>/dev/null; printf $?)" -eq 0 ] && return 0 || return 1
}

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
}
