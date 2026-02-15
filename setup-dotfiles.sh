#!/bin/bash
#
# Symlink dotfiles
# this symlinks all the dotfiles (and .vim/) to ~/
# it also symlinks ~/bin for easy updating
#
# this is safe to run multiple times and will prompt you about anything unclear

# sources:
#   https://github.com/paulirish/dotfiles/blob/master/symlink-setup.sh
#   https://raw.githubusercontent.com/alrra/dotfiles/master/os/create_symbolic_links.sh

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

#
# actual symlink stuff
#

# Symlink line: target (bright gray) ← source (dark gray).
# code 0 = ✓ green, else ✗ red.
print_symlink_result() {
  local code=$1 target=$2 source=$3
  [ "$PLAIN" = 0 ] && printf '\r\033[K'
  if [ "$code" -eq 0 ]; then
    printf '\033[0;32m ✓ \033[97m%s\033[0m ← \033[90m%s\033[0m\n' "$target" "$source"
  else
    printf '\033[0;31m ✗ \033[97m%s\033[0m ← \033[90m%s\033[0m\n' "$target" "$source"
  fi
}


# finds all .dotfiles in this folder
declare -a FILES_TO_SYMLINK=$(find dotfiles -type f -name ".*" -not -name .DS_Store -not -name .git -not -name .osx | sed -e 's|//|/|')
# | sed -e 's|./.|.|')
FILES_TO_SYMLINK="$FILES_TO_SYMLINK bin" # add in vim and the binaries

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
        sourceFile="$(pwd)/$i"
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

