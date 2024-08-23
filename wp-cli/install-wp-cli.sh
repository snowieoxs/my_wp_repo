#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Using cURL downlaod WP-CLI:
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Test that is works
echo
echo "***********************************************************************************************************"
echo
php wp-cli.phar --info
echo
echo "***********************************************************************************************************"
echo

# Prompt the user
read -p "Did it work? yY/nN: " response

# Check the user's input
if [[ "$response" =~ ^[yY]$ ]]; then
    echo "Continuing the script..."
else
    echo "Exiting the script..."
    exit 1
fi

# Make it executable
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Test that it works
echo
echo "***********************************************************************************************************"
echo
echo "wp-cli.phar has been moved to /usr/local/bin/wp"
echo
echo "Test that i works by typing 'wp'"
echo