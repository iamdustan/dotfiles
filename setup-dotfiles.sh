#!/bin/bash
#
# Symlink dotfiles and bin to ~. Safe to run multiple times; prompts on overwrite.

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

# When PLAIN=0, clear line before printing (same as print_step_ok).
print_symlink_result() {
  local code=$1 target=$2 source=$3
  [ "$PLAIN" = 0 ] && printf '\r\033[K'
  if [ "$code" -eq 0 ]; then
    printf '\033[0;32m ✓ \033[97m%s\033[0m ← \033[90m%s\033[0m\n' "$target" "$source"
  else
    printf '\033[0;31m ✗ \033[97m%s\033[0m ← \033[90m%s\033[0m\n' "$target" "$source"
  fi
}

declare -a FILES_TO_SYMLINK=$(cd "$SETUP_ROOT" && find dotfiles -type f -name ".*" -not -name .DS_Store -not -name .git -not -name .osx | sed -e 's|//|/|')
FILES_TO_SYMLINK="$FILES_TO_SYMLINK bin"

main() {
    local i=""
    local sourceFile=""
    local targetFile=""
    local code=0

    if [ "$PLAIN" = 1 ]; then
        print_info "Symlinking dotfiles"
    else
        step_start "Symlinking dotfiles"
        printf "\n"
    fi

    for i in ${FILES_TO_SYMLINK[@]}; do
        sourceFile="$SETUP_ROOT/$i"
        targetFile="$HOME/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"
        displayTarget="${targetFile/#$HOME/~}"
        displaySource="${sourceFile/#$HOME/~}"

        if [ -e "$targetFile" ]; then
            if [ "$(readlink "$targetFile")" != "$sourceFile" ]; then
                ask_for_confirmation "'$displayTarget' already exists, do you want to overwrite it?"
                if answer_is_yes; then
                    rm -rf "$targetFile"
                    ln -fs "$sourceFile" "$targetFile" &>/dev/null
                    code=$?
                    print_symlink_result $code "$displayTarget" "$displaySource"
                else
                    print_symlink_result 1 "$displayTarget" "$displaySource"
                    code=1
                fi
            else
                code=0
                print_symlink_result 0 "$displayTarget" "$displaySource"
            fi
        else
            ln -fs "$sourceFile" "$targetFile" &>/dev/null
            code=$?
            print_symlink_result $code "$displayTarget" "$displaySource"
        fi
    done

    if [ "$PLAIN" = 1 ]; then
        print_info "  Finished symlinking dotfiles"
    else
        step_end $code "Finished symlinking dotfiles"
    fi
}

main

