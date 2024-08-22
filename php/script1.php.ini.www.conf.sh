#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit if the target configuration file does not exist
if [ ! -f /etc/php/8.3/fpm/pool.d/www.conf ]; then
    echo "***********************************************************************************************************"
    echo "/etc/php/8.3/fpm/pool.d/www.conf does not exist. Exiting..."
    exit 1
fi

if [ ! -f /etc/php/8.3/fpm/php.ini ]; then
    echo "***********************************************************************************************************"
    echo "/etc/php/8.3/fpm/php.ini does not exist. Exiting..."
    exit 1
fi

# Create a backup of the current configuration with a timestamp
timestamp=$(date +"%Y_%m_%d_%H_%M_%S")

# sudo cp /etc/php/8.3/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/www.conf_$timestamp

# sudo cp /etc/php/8.3/fpm/php.ini /etc/php/8.3/fpm/php.ini_$timestamp

# Append the backup file path to the list of backups
echo "/etc/php/8.3/fpm/pool.d/www.conf.bak1_$timestamp" >> "$SCRIPT_DIR/listofbaks"

echo "/etc/php/8.3/fpm/php.ini.bak1_$timestamp" >> "$SCRIPT_DIR/listofbaks"

# Export variables 
export PHP_USER="$USER"
###
export UPLOAD_MAX_FILESIZE="64m"
export POST_MAX_SIZE="64m"
export OPCACHE_ENABLE_FILE_OVERRIDE="opcache.enable_file_override = 1" #this line is commented out

# Replace variables in the template file and copy to destination
envsubst < "$SCRIPT_DIR/template1.www.conf" | sudo tee /etc/php/8.3/fpm/pool.d/www.conf > /dev/null

envsubst < "$SCRIPT_DIR/template1.php.ini" | sudo tee /etc/php/8.3/fpm/php.ini > /dev/null

echo "Backup created and new configuration applied."

# Test the new configuration
sudo php-fpm8.3 -t

# If the test is successful, reload Nginx
if [ $? -eq 0 ]; then
    sudo service php8.3-fpm restart
else
    echo "***********************************************************************************************************"
    echo "php-fpm8.3 configuration test failed. Not restarting PHP-FPM."
fi