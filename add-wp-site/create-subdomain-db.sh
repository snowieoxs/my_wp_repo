#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Function to handle errors
handle_error() {
    echo "***********************************************************************************************************"
    echo "Error on line $2: $1"
    exit 1
}

# Load environment variables from the .env file
ENV_FILE="$SCRIPT_DIR/.env"

[ -f "$ENV_FILE" ] || handle_error ".env file not found in $SCRIPT_DIR" $LINENO

set -o allexport
source "$ENV_FILE" || handle_error "Failed to source .env file." $LINENO
set +o allexport

# Check if DB_PASSWORD and ANOTHER_VAR are set and not empty
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    handle_error "DB_PASSWORD is not set in the .env file. Please edit $ENV_FILE and set DB_PASSWORD=your_secure_password" $LINENO
fi

if [ -z "$MYSQL_CNAME_PASSWORD" ]; then
    handle_error "MYSQL_CNAME_PASSWORD is not set in the .env file. Please edit $ENV_FILE and set ANOTHER_VAR=your_value" $LINENO
fi

# Create subdomain database
mysql -u root -p "$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $CNAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
CREATE USER '$CNAME'@'localhost' IDENTIFIED BY '$MYSQL_CNAME_PASSWORD';
GRANT ALL PRIVILEGES ON $CNAME.* TO '$CNAME'@'localhost';
# GRANT SELECT, INSERT, UPDATE, DELETE ON globex.* TO 'globex'@'localhost';
FLUSH PRIVILEGES;
EOF

# Function to execute the create-subdomain-db script
run_install_wp() {
    local install_wp_script="$SCRIPT_DIR/install-wp.sh"

    if [ ! -f "$install_wp_script" ]; then
        handle_error "install-wp.sh script not found." $LINENO
    fi

    chmod +x "$install_wp_script"
    "$install_wp_script" || handle_error "install-wp.sh script failed." $LINENO
}

run_install_wp

echo "Subdomain database created successfully."