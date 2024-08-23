#!/bin/bash
# obtain-ssl-cert.sh

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"



# When we went through the process to install Nginx you may remember we created a php.info file in the /var/www/html directory. This was because this is the default document root that Nginx configures. However, we want a more manageable directory structure for our WordPress sites.
# Add server block so that NGINX can deal with request for the domain
mkdir -p ~/"$SUB_DOMAIN"/logs ~/"$SUB_DOMAIN"/public
chmod -R 755 ~/"$SUB_DOMAIN"


# Replace variables in the template file and save to a temporary file
SITES_AVAILABLE_CNAME_TEMPLATE=$(mktemp)
envsubst < "$SCRIPT_DIR/sites-available-cname-template" > "$SITES_AVAILABLE_CNAME_TEMPLATE"

# Read the content of the temporary file and write it to /etc/nginx/sites-available/$SUB_DOMAIN
cat "$SITES_AVAILABLE_CNAME_TEMPLATE" | sudo tee /etc/nginx/sites-available/$SUB_DOMAIN > /dev/null
if [ $? -ne 0 ]; then
    echo "Failed to write Nginx configuration."
    rm "$SITES_AVAILABLE_CNAME_TEMPLATE"
    exit 1
fi

# Optionally, remove the temporary file
rm "$SITES_AVAILABLE_CNAME_TEMPLATE"

# Enable newly created site
sudo ln -s /etc/nginx/sites-available/"$SUB_DOMAIN" /etc/nginx/sites-enabled/"$SUB_DOMAIN"
if [ $? -ne 0 ]; then
    echo "Failed to enable the new site."
    exit 1
fi

# Test the new configuration
sudo nginx -t

# Test the new configuration
sudo nginx -t

# If the test is successful, reload Nginx
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx

    # Check if the script exists and is executable
    CREATE_SUBDOMAIN_DB_SCRIPT="$SCRIPT_DIR/create-subdomain-db.sh"

    if [ -f "$CREATE_SUBDOMAIN_DB_SCRIPT" ]; then
        chmod +x "$CREATE_SUBDOMAIN_DB_SCRIPT"
        "$CREATE_SUBDOMAIN_DB_SCRIPT"
        if [ $? -ne 0 ]; then
            echo "***********************************************************************************************************"
            echo "create-subdomain-db.sh script failed."
            exit 1
        fi
    else
        echo "***********************************************************************************************************"
        echo "create-subdomain-db.sh script not found."
        exit 1
    fi
else
    echo "***********************************************************************************************************"
    echo "Nginx configuration test failed. Not restarting Nginx."
    exit 1
fi