#!/bin/bash

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

# Check if the Nginx configuration file exists
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "Error: /etc/nginx/nginx.conf does not exist."
    exit 1
fi

# Create a timestamp for the backup
timestamp=$(date +"%Y%m%d%H%M%S")

# Backup the existing Nginx configuration file
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak_$timestamp

# Replace variables in the template file and copy to destination
envsubst < ./nginx.template1.conf > /etc/nginx/nginx.conf

# Inform the user
echo "Backup created and new configuration applied."

# test it
sudo nginx -t

# restart it
service nginx restart