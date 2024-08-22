#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit if the target configuration file does not exist
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "***********************************************************************************************************"
    echo "/etc/nginx/nginx.conf does not exist. Exiting..."
    exit 1
fi

# Create a backup of the current configuration with a timestamp
timestamp=$(date +"%Y_%m_%d_%H_%M_%S")
# sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak2_$timestamp

# Append the backup file path to the list of backups
echo "/etc/nginx/nginx.conf.bak2_$timestamp" >> "$SCRIPT_DIR/listofbaks"

# Define your variables
ulimit_n=$(ulimit -n)
num_cores=$(grep -c processor /proc/cpuinfo)
utilization_factor=0.90

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

# Define the server block as a variable
SERVER_BLOCK=$(cat <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
)

# Replace variables in the template file and save to a temporary file
NGINX2_TEMP_CONF=$(mktemp)
envsubst < "$SCRIPT_DIR/template2.nginx.conf" > "$NGINX2_TEMP_CONF"

# Use awk to replace the placeholder with the actual server block
awk -v server_block="$SERVER_BLOCK" '
    /# SERVER_BLOCK_PLACEHOLDER/ { 
        print server_block; 
        next 
    } 
    { 
        print 
    }' "$NGINX2_TEMP_CONF" | sudo tee /etc/nginx/nginx.conf > /dev/null

# Clean up temporary file
rm "$NGINX2_TEMP_CONF"

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


# EXAMPLE OF AWK WITH INDENTATION HANDLED IN A WAY THAT IS EASIER TO READ
# # Define the server block as a variable
# SERVER_BLOCK=$(cat <<'EOF'
#     server {
#         listen 80 default_server;
#         listen [::]:80 default_server;
#         server_name _;
#         return 444;
#     }
# EOF
# )

# # Use awk to replace the placeholder with the actual server block
# awk -v block="$SERVER_BLOCK" '
# /# SERVER_BLOCK_PLACEHOLDER/ {print block; next} {print}
# ' "$TEMP_CONF" | sudo tee /etc/nginx/nginx.conf > /dev/null


