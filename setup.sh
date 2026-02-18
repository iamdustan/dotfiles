#!/bin/bash
#
# Setup a new machine!
#

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_ROOT/setup-common.sh" "$@"

# Install applications
"$SETUP_ROOT/install.sh" "$@"

# Setup dotfiles
"$SETUP_ROOT/setup-dotfiles.sh" "$@"

# Setup applications
"$SETUP_ROOT/setup-apps.sh" "$@"

# Setup AI agents
if [ "$INTERACTIVE" = 1 ]; then
  "$SETUP_ROOT/bin/setup-agents"
fi
