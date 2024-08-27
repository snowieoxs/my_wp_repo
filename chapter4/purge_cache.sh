#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the name of the script file
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
# Source the config file
source "$SCRIPT_DIR/config.sh"

# purge entire cache
sudo rm -Rf /home/$USER/$SUB_DOMAIN/cache/*