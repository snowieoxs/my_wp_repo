#!/bin/bash

# This script is going to give you a warning "[warn] 43484#43484: no "fastcgi_cache_key" for "fastcgi_cache" in /etc/nginx/nginx.conf:74" should be fine after the next script

# Notice how the fastcgi_cache directive matches the keys_zone set before the server block. In addition to changing the cache location, you can also specify the cache duration by replacing 60m with the desired duration in minutes. The default of 60 minutes is a good starting point for most people.

# If you modify the cache duration, you should consider updating the inactive parameter in the fastcgi_cache_path line as well. The inactive parameter specifies the length of time cached data is allowed to live in the cache without being accessed before it is removed.

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
CACHE_EXCLUSIONS=$(cat <<'EOF'
    # Cache Exclusions
    set $skip_cache 0;
    
    # POST requests should always go to PHP
    if ($request_method = POST) {
        set $skip_cache 1;
    }
    
    # URLs containing query strings should always go to PHP
    if ($query_string != "") {
        set $skip_cache 1;
    }
    
    # Don't cache uris containing the following segments
    if ($request_uri ~* "/wp-admin/|/wp-json/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
        set $skip_cache 1;
    }
    
    # Don't use the cache for logged in users or recent commenters
    if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
        set $skip_cache 1;
    }
EOF
)

PAGE_CACHE_PHP_FPM=$(cat <<'EOF'
        fastcgi_cache {{SUB_DOMAIN}};
        fastcgi_cache_bypass $skip_cache;
        fastcgi_no_cache $skip_cache;
        fastcgi_cache_valid 60m; # This can be changed, they talk about it in the documentation
EOF
)

# Replace the placeholder in PAGE_CACHE_PHP_FPM
PAGE_CACHE_PHP_FPM=$(echo "$PAGE_CACHE_PHP_FPM" | sed "s|{{SUB_DOMAIN}}|$SUB_DOMAIN|g")

# Function to configure the Nginx template
configure_sites_available_template() {
    local temp_file
    temp_file=$(mktemp)

    # Copy the contents of the template file to the temporary file
    cp "$SCRIPT_DIR/sites-available-template.conf" "$temp_file"

    # Replace placeholders in the temporary file using sed
    sed -i -e "s|{{SUB_DOMAIN}}|$SUB_DOMAIN|g" \
           -e "s|{{USERNAME}}|$USERNAME|g" \
           -e "s|{{WWW_SUB_DOMAIN}}|$WWW_SUB_DOMAIN|g" "$temp_file"


    # Insert the server block and cache settings using awk
    awk -v cache_exclusions="$CACHE_EXCLUSIONS" -v page_cache_php_fpm="$PAGE_CACHE_PHP_FPM" '
    /# CACHE_EXCLUSIONS_PLACEHOLDER/ {print cache_exclusions; next}
    /# PAGE_CACHE_PHP_FPM_PLACEHOLDER/ {print page_cache_php_fpm; next}
    {print}
    ' "$temp_file" | sudo tee /etc/nginx/sites-available/"$SUB_DOMAIN" > /dev/null || handle_error "Failed to write sites available configuration." $LINENO
    
    # Clean up the temporary file
    rm "$temp_file"
}

# Function to test and reload Nginx
reload_nginx() {
    sudo nginx -t || handle_error "Nginx configuration test failed. Not restarting Nginx." $LINENO
    sudo systemctl restart nginx || handle_error "Failed to restart Nginx." $LINENO
}

# Main execution flow
configure_sites_available_template
reload_nginx

echo "sites available conf completed successfully. $SCRIPT_NAME script finished."