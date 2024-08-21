#!/bin/bash

# Exit if the target configuration file does not exist
if [ ! -f /etc/php/8.3/fpm/pool.d/www.conf ]; then
    echo "/etc/php/8.3/fpm/pool.d/www.conf does not exist. Exiting..."
    exit 1
fi

# Create a backup of the current configuration with a timestamp
timestamp=$(date +"%Y%m%d%H%M%S")
sudo cp /etc/php/8.3/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/www.conf_$timestamp

# Export variables
export PHP_USER="$USER"

# Replace variables in the template file and copy to destination
envsubst < ./template1.www.conf | sudo tee /etc/php/8.3/fpm/pool.d/www.conf > /dev/null
