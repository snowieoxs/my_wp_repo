#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit if the target configuration file does not exist
if [ ! -f /etc/php/8.3/fpm/pool.d/www.conf ]; then
    echo "/etc/php/8.3/fpm/pool.d/www.conf does not exist. Exiting..."
    exit 1
fi

if [ ! -f /etc/php/8.3/fpm/php.ini ]; then
    echo "/etc/php/8.3/fpm/php.ini does not exist. Exiting..."
    exit 1
fi

# Create a backup of the current configuration with a timestamp
timestamp=$(date +"%Y%m%d%H%M%S")

sudo cp /etc/php/8.3/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/www.conf_$timestamp

sudo cp /etc/php/8.3/fpm/php.ini /etc/php/8.3/fpm/php.ini_$timestamp

# Export variables 
export PHP_USER="$USER"
###
export UPLOAD_MAX_FILESIZE="64m"
export POST_MAX_SIZE="64m"
export OPCACHE_ENABLE_FILE_OVERRIDE="opcache.enable_file_override = 1" #this line is commented otu

# Replace variables in the template file and copy to destination
envsubst < "$SCRIPT_DIR/template1.www.conf" | sudo tee /etc/php/8.3/fpm/pool.d/www.conf > /dev/null

echo "Backup created and new configuration applied."