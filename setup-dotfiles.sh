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

# finds all .dotfiles in this folder
declare -a FILES_TO_SYMLINK=$(find dotfiles -type f -name ".*" -not -name .DS_Store -not -name .git -not -name .osx | sed -e 's|//|/|')
# | sed -e 's|./.|.|')
FILES_TO_SYMLINK="$FILES_TO_SYMLINK bin" # add in vim and the binaries

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    local i=""
    local sourceFile=""
    local targetFile=""

    for i in ${FILES_TO_SYMLINK[@]}; do

        sourceFile="$(pwd)/$i"
        targetFile="$HOME/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ -e "$targetFile" ]; then
            if [ "$(readlink "$targetFile")" != "$sourceFile" ]; then

                ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
                if answer_is_yes; then
                    rm -rf "$targetFile"
                    execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
                else
                    print_error "$targetFile → $sourceFile"
                fi

            else
                print_success "$targetFile → $sourceFile"
            fi
        else
            execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
        fi

    done

}

print_info "Symlinking dotfiles"

main

print_info "  Finished symlinking dotfiles"

