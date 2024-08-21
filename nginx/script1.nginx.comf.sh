#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit if the target configuration file does not exist
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "/etc/nginx/nginx.conf does not exist. Exiting..."
    exit 1
fi

# Create a backup of the current configuration with a timestamp
timestamp=$(date +"%Y%m%d%H%M%S")
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak_$timestamp

# Define your variables
ulimit_n=$(ulimit -n)
num_cores=$(grep -c processor /proc/cpuinfo)
utilization_factor=0.80

# Calculate worker_connections
worker_connections=$(echo "$ulimit_n * $num_cores * $utilization_factor" | bc)
worker_connections=$(printf "%.0f" $worker_connections)  # Round to the nearest integer

# Export variables
export NGINX_USER="$USER"
export WORKER_PROCESSES=$num_cores
export WORKER_CONNECTIONS=$worker_connections
export MULTI_ACCEPT="on"
export KEEPALIVE_TIMEOUT="15"
export SERVER_TOKENS="off"
export CLIENT_MAX_BODY_SIZE="64m"
export GZIP_PROXIED="any"
export GZIP_COMP_LEVEL="5"
export GZIP_TYPES="text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript"

# Replace variables in the template file and copy to destination
envsubst < "$SCRIPT_DIR/template1.nginx.conf" | sudo tee /etc/nginx/nginx.conf > /dev/null

echo "Backup created and new configuration applied."

# Test the new configuration
sudo nginx -t

# If the test is successful, reload Nginx
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx
else
    echo "Nginx configuration test failed. Not restarting Nginx."
fi
