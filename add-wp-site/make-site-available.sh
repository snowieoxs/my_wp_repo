#!/bin/bash
# obtain-ssl-cert.sh

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Function to handle errors
handle_error() {
    echo "***********************************************************************************************************"
    echo "make-site-available.sh Error on line $2: $1"
    exit 1
}

# Function to create the directory structure
setup_directories() {
    mkdir -p ~/"$SUB_DOMAIN"/{logs,public} || handle_error "Failed to make ~/'$SUB_DOMAIN'/{logs,public}" $LINENO
    chmod -R 755 ~/"$SUB_DOMAIN" || handle_error "Failed to set permissions for $SUB_DOMAIN directory." $LINENO
}

# Function to replace placeholders using sed
replace_placeholders() {
    sed -e "s|{{SUB_DOMAIN}}|$SUB_DOMAIN|g" \
        -e "s|{{WWW_SUB_DOMAIN}}|$WWW_SUB_DOMAIN|g" \
        -e "s|{{USERNAME}}|$USERNAME|g" \
        "$SCRIPT_DIR/sites-available-template.conf"
}

configure_site_available () {
    local site_available_temp_config
    site_available_temp_config=$(mktemp)

    # Replace placeholders in the template file and save to a temporary file
    replace_placeholders > "$site_available_temp_config"

    # Write the configuration to /etc/nginx/sites-available/$SUB_DOMAIN
    sudo tee /etc/nginx/sites-available/"$SUB_DOMAIN" < "$site_available_temp_config" > /dev/null || handle_error "Failed to write Nginx configuration." $LINENO
    rm "$site_available_temp_config"

    # Enable the site with symbolic link
    sudo ln -s /etc/nginx/sites-available/"$SUB_DOMAIN" /etc/nginx/sites-enabled/"$SUB_DOMAIN" || handle_error "Failed to enable the new site." $LINENO
}

# Functio to test and reload Nginx
reload_nginx() {
    sudo nginx -t || handle_error "Nginx configuration test failed. Not restarting Nginx." $LINENO
    sudo systemctl restart nginx || handle_error "Failed to restart Nginx." $LINENO
}

# Function to execute the create-subdomain-db script
# run_create_db_script() {
#     local db_script="$SCRIPT_DIR/create-subdomain-db.sh"

#     if [ -f "$db_script" ]; then
#         chmod +x "$db_script"
#         "$db_script" || handle_error "create-subdomain-db.sh script failed." $LINENO
#     else
#         handle_error "create-subdomain-db.sh script not found." $LINENO
#     fi
# }

# Main script execution
setup_directories
configure_site_available
reload_nginx
# run_create_db_script

chmod +x "$SCRIPT_DIR/create-subdomain-db.sh"
echo "make-site-available.sh completed successfully."