#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit if the target configuration file does not exist
if [ ! -f /etc/nginx/sites-available/default ]; then
    echo "***********************************************************************************************************"
    echo "/etc/nginx/sites-available/default does not exist. Exiting..."
    exit 1
fi

# Create a backup of the current configuration with a timestamp
timestamp=$(date +"%Y_%m_%d_%H_%M_%S")
# sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak_$timestamp

# Append the backup file path to the list of backups
echo "/etc/nginx/sites-available/default.bak_$timestamp" >> "$SCRIPT_DIR/listofbaks"

# Export variables
export INCLUDE_FACTCGI_PHP="location ~ \.php$ {include snippets/fastcgi-php.conf; fastcgi_pass unix:/run/php/php8.3-fpm.sock;}"

# Replace variables in the template file and copy to destination
envsubst < "$SCRIPT_DIR/template1.default" | sudo tee /etc/nginx/sites-available/default > /dev/null

echo "Backup created and new configuration applied."

# Test the new configuration
sudo nginx -t

# If the test is successful, reload Nginx
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx
else
    echo "***********************************************************************************************************"
    echo "Nginx configuration test failed. Not restarting Nginx."
fi

# Create a PHP info file
if [ -d "/var/www/html" ]; then
    echo "<?php phpinfo();" | sudo tee /var/www/html/info.php > /dev/null
    sudo chown $USER:$USER /var/www/html/info.php
    echo "***********************************************************************************************************"
    echo "info.php has been created."
else
    echo "***********************************************************************************************************"
    echo "/var/www/html does not exist."
fi