#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the name of the script file
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
# Source the config file
source "$SCRIPT_DIR/config.sh"

# Function to handle errors
handle_error() {
    echo "***********************************************************************************************************"
    echo "$SCRIPT_NAME Error on line $2: $1"
    exit 1
}

# Add the Official Redis package repository
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg || handle_error "Failed to add the Redis package repository key." $LINENO
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list || handle_error "Failed to add the Redis package repository." $LINENO
sudo apt update || handle_error "Failed to update package list." $LINENO

# Install Redis server and restart PHP-FPM:
sudo apt install redis-server -y || handle_error "Failed to install Redis server." $LINENO
sudo service php8.3-fpm restart || handle_error "Failed to restart PHP-FPM." $LINENO

# Enaable redis-server
sudo systemctl enable redis-server || handle_error "Failed to enable Redis server." $LINENO

chmod +x configure-page-cache.sh
echo "Redis server installed successfully, $SCRIPT_NAME finished."
