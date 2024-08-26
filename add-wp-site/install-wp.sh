#!/bin/bash
# install-wp.sh

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Function to handle errors
handle_error() {
    echo "***********************************************************************************************************"
    echo "install-wp.sh Error on line $2: $1"
    exit 1
}

# Load environment variables from the .env file
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    # Export all variables from the .env file
    set -o allexport
    source "$ENV_FILE" || handle_error "Failed to source .env file." $LINENO
    set +o allexport
else
    handle_error ".env file not found in $SCRIPT_DIR" $LINENO
fi

# Check if DB_PASSWORD is set and not empty
if [ -z "$DB_PASSWORD" ]; then
    handle_error "DB_PASSWORD is not set in the .env file. Please edit $ENV_FILE and set DB_PASSWORD=your_secure_password" $LINENO
fi

# Check if WP_PASSWORD is set and not empty
if [ -z "$WP_PASSWORD" ]; then
    handle_error "WP_PASSWORD is not set in the .env file. Please edit $ENV_FILE and set DB_PASSWORD=your_secure_password" $LINENO
fi

# Go to your site's public directory
cd ~/$SUB_DOMAIN/public || handle_error "Failed to change directory to ~/$SUB_DOMAIN/public." $LINENO

# Download the latest version of WordPress
wp core download || handle_error "Failed to download WordPress." $LINENO

# Create wp-config.php file
wp core config --dbname="$CNAME" --dbuser="$CNAME" --dbpass="$DB_PASSWORD" || handle_error "Failed to create wp-config.php file." $LINENO

# with wp-config.php created, we can now install WordPress
wp core install --skip-email --url="$URL" --title="$TITLE" --admin_user="$USERNAME" --admin_password="$WP_PASSWORD" --admin_email="$WP_EMAIL" || handle_error "Failed to install WordPress." $LINENO

echo "***********************************************************************************************************"
echo "you shoudld see the message 'Success: WordPress installed successfully.' Script if finished."

