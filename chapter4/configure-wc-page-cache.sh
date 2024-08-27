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

WOO_COMMERCE_CACHE_EXCLUSIONS=$(cat <<'EOF'
    # Don’t use cache for WooCommerce pages
    if ($request_uri ~* "/(cart|checkout|my-account)/*$") {
        set $skip_cache 1;
    }

    # Don't use the cache when cart contains items
    if ($http_cookie ~* "woocommerce_items_in_cart") {
        set $skip_cache 1;
    }
EOF
)

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
    awk -v cache_exclusions="$CACHE_EXCLUSIONS" -v woo_commerce_cache_exclusions="$WOO_COMMERCE_CACHE_EXCLUSIONS" '
    /# CACHE_EXCLUSIONS_PLACEHOLDER/ {print cache_exclusions; next}
    /# WOO_COMMERCE_CACHE_EXCLUSIONS_PLACEHOLDER/ {print woo_commerce_cache_exclusions; next}
    {print}
    ' "$temp_file" | sudo tee /etc/nginx/sites-available/"$SUB_DOMAIN" > /dev/null || handle_error "Failed to write sites available configuration." $LINENO
    
    # Clean up the temporary file
    rm "$temp_file"
}

Function to test and reload Nginx
reload_nginx() {
    sudo nginx -t || handle_error "Nginx configuration test failed. Not restarting Nginx." $LINENO
    sudo systemctl restart nginx || handle_error "Failed to restart Nginx." $LINENO
}

# Main execution flow
configure_sites_available_template
reload_nginx

echo "sites available conf completed successfully. $SCRIPT_NAME script finished."