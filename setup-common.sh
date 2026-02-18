#!/bin/bash
# Shared flags and helpers for setup scripts.
# Source with: source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-common.sh" "$@"

# Parse -i/--interactive, -p/--plain from "$@" (no shift so caller's "$@" is unchanged)
INTERACTIVE=0
PLAIN=0
for _arg in "$@"; do
  case "$_arg" in
    -i|--interactive) INTERACTIVE=1 ;;
    -p|--plain)       PLAIN=1 ;;
  esac
done

# --- Print helpers ---

print_error() {
  printf '\033[0;31m ✗ %s\033[0m\n' "$1"
}

print_info() {
  printf '\033[0;35m %s\033[0m\n' "$1"
}

print_question() {
  printf '\033[0;33m  [?] %s\033[0m' "$1"
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"
  [ "${3:-}" = "true" ] && [ $1 -ne 0 ] && exit
}

print_success() {
  printf '\033[0;32m ✓ %s\033[0m\n' "$1"
}

print_note() {
  printf '\033[90m %s \033[37m%s\033[0m\n' "$1" "$2"
}

# Optional-step helper: when INTERACTIVE=1, prompt (y/n); when not, use default.
# Usage: confirm_optional "Install Amethyst? [y/N]" "no"  → returns 0 (yes) or 1 (no/skip).
# Default must be "yes" or "no". Returns 0 to proceed, 1 to skip.
confirm_optional() {
  local prompt="$1"
  local default="${2:-no}"
  if [ "$INTERACTIVE" = 1 ]; then
    if [ "$default" = "yes" ]; then
      print_question "$prompt [Y/n] "
    else
      print_question "$prompt [y/N] "
    fi
    read -n 1 -r
    printf "\n"
    if [[ "${REPLY:-}" =~ ^[Yy]$ ]]; then return 0; fi
    if [[ "${REPLY:-}" =~ ^[Nn]$ ]]; then return 1; fi
    [ "$default" = "yes" ] && return 0 || return 1
  fi
  [ "$default" = "yes" ] && return 0 || return 1
}

# When PLAIN=0, clear the current line before printing so one line updates in place.
print_step_ok() {
  [ "$PLAIN" = 0 ] && printf '\r\033[K'
  print_success "$1"
}
print_step_fail() {
  [ "$PLAIN" = 0 ] && printf '\r\033[K'
  print_error "$1"
}

# --- Step helpers (inline output when PLAIN=0) ---

STEP_SPINNER=('◐' '◓' '◑' '◒')
STEP_DOTS=(
  $'\033[90m.\033[0m\033[90m.\033[0m\033[90m.\033[0m'
  $'\033[90m.\033[0m\033[90m.\033[0m.'
  $'\033[90m.\033[0m.\033[90m.\033[0m'
  $'.\033[90m.\033[0m\033[90m.\033[0m'
)

# PLAIN=1: no-op. Otherwise: one line with spinner + message (no newline).
step_start() {
  if [ "$PLAIN" = 1 ]; then
    :
  else
    printf '\r\033[K %s %s %s' "${STEP_SPINNER[0]}" "$1" "${STEP_DOTS[0]}"
  fi
}

step_end() {
  local code=$1
  local msg=$2
  if [ "$code" -eq 0 ]; then
    print_step_ok "$msg"
  else
    print_step_fail "$msg"
  fi
}

# Long-running command: when PLAIN=0 run in background and animate spinner on one line; when PLAIN=1 run in foreground.
run_with_spinner() {
  local msg=$1
  shift
  if [ "$PLAIN" = 1 ]; then
    "$@"
    return $?
  fi
  ("$@" &>/dev/null) &
  local pid=$!
  local sp=0 dot=0
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r\033[K %s %s %s' "${STEP_SPINNER[sp]}" "$msg" "${STEP_DOTS[dot]}"
    sp=$(( (sp + 1) % ${#STEP_SPINNER[@]} ))
    dot=$(( (dot + 1) % ${#STEP_DOTS[@]} ))
    sleep 0.10
  done
  wait "$pid"
  return $?
}

when_plain() {
  [ "$PLAIN" = 1 ] && "$@"
}

# --- Shared helpers ---

cmd_exists() {
  [ -x "$(command -v "$1")" ] && return 0 || return 1
}

file_exists() {
  [ -d "$1" ] && return 0 || return 1
}

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

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      mkdir -p "$1" &>/dev/null
      print_result $? "$1"
    fi
  fi
}
