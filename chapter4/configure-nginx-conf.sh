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

# Define the server block and cache settings as variables
SERVER_BLOCK=$(cat <<'EOF'
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        return 444;
    }
EOF
)

CACHE_SETTINGS=$(cat <<'EOF'
    ##
    # Cache Settings
    ##
    
    fastcgi_cache_key "$scheme$request_method$http_host$request_uri";
    add_header Fastcgi-Cache $upstream_cache_status;
EOF
)

# Function to configure the Nginx template
configure_chapter4_nginx_template() {
    local temp_file
    temp_file=$(mktemp)

    # Copy the contents of the template file to the temporary file
    cp "$SCRIPT_DIR/nginx-template.conf" "$temp_file"

    # Replace placeholders in the temporary file using sed
    sed -i -e "s|{{NGINX_USER}}|$NGINX_USER|g" \
           -e "s|{{WORKER_PROCESSES}}|$WORKER_PROCESSES|g" \
           -e "s|{{WORKER_CONNECTIONS}}|$WORKER_CONNECTIONS|g" \
           -e "s|{{MULTI_ACCEPT}}|$MULTI_ACCEPT|g" \
           -e "s|{{KEEPALIVE_TIMEOUT}}|$KEEPALIVE_TIMEOUT|g" \
           -e "s|{{SERVER_TOKENS}}|$SERVER_TOKENS|g" \
           -e "s|{{CLIENT_MAX_BODY_SIZE}}|$CLIENT_MAX_BODY_SIZE|g" \
           -e "s|{{GZIP_PROXIED}}|$GZIP_PROXIED|g" \
           -e "s|{{GZIP_COMP_LEVEL}}|$GZIP_COMP_LEVEL|g" \
           -e "s|{{GZIP_TYPES}}|$GZIP_TYPES|g" "$temp_file"

    # Insert the server block and cache settings using awk
    awk -v server_block="$SERVER_BLOCK" -v cache_settings="$CACHE_SETTINGS" '
    /# SERVER_BLOCK_PLACEHOLDER/ {print server_block; next}
    /# CACHE_SETTINGS_PLACEHOLDER/ {print cache_settings; next}
    {print}
    ' "$temp_file" | sudo tee /etc/nginx/nginx.conf > /dev/null || handle_error "Failed to write Nginx configuration." $LINENO
    
    # Clean up the temporary file
    rm "$temp_file"
}

# Function to test and reload Nginx
reload_nginx() {
    sudo nginx -t || handle_error "Nginx configuration test failed. Not restarting Nginx." $LINENO
    sudo systemctl restart nginx || handle_error "Failed to restart Nginx." $LINENO
}

# Main execution flow
configure_chapter4_nginx_template
reload_nginx

echo "Nginx configuration for chapter4 completed successfully. $SCRIPT_NAME script finished."