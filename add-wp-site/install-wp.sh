#!/bin/bash
# install-wp.sh

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load sensitive information from .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
    if [ $? -ne 0 ]; then
        echo "Failed to export variables from .env file."
        exit 1
    fi
else
    echo ".env file not found in $SCRIPT_DIR"
    echo "Please create one and add 'DB_PASSWORD=your_secure_password'"
    exit 1
fi

# Source the non-sensitive configuration
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
    if [ $? -ne 0 ]; then
        echo "Failed to source config.sh."
        exit 1
    fi
else
    echo "config.sh file not found in $SCRIPT_DIR"
    exit 1
fi

# Go to your site's public directory
cd ~/$SUB_DOMAIN/public
if [ $? -ne 0 ]; then
    echo "Failed to change directory to ~/"$SUB_DOMAIN"/public."
    exit 1
fi

# Download the latest version of WordPress
wp core download
if [ $? -ne 0 ]; then
    echo "Failed to download WordPress."
    exit 1
fi

# Create wp-config.php file
wp core config --dbname="$CNAME" --dbuser="$CNAME" --dbpass="$DB_PASSWORD"
if [ $? -ne 0 ]; then
    echo "Failed to create wp-config.php file."
    exit 1
fi

echo "WordPress setup completed successfully."
