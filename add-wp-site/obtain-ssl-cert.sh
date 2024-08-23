#!/bin/bash
# obtain-ssl-cert.sh

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Create a backup of the current configuration with a timestamp
timestamp=$(date +"%Y_%m_%d_%H_%M_%S")

# Idk you are going to have to take a look at this, and mess around with cloud config
# sudo apt install software-properties-common
# sudo add-apt-repository universe
sudo apt update
sudo apt install certbot python3-certbot-nginx
if [ $? -ne 0 ]; then
    echo "Failed to install certbot and dependencies."
    exit 1
fi

# Obtain the SSL certificate
sudo certbot --nginx -d $SUB_DOMAIN -d $WWW_CNAME
if [ $? -ne 0 ]; then
    echo "Failed to obtain SSL certificate."
    exit 1
fi

# Take not of where the cert is saved because you will need it later
# Successfully received certificate.
# Certificate is saved at: /etc/letsencrypt/live/globex.turnipjuice.media/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/globex.turnipjuice.media/privkey.pem

# Test automatic renewal process
sudo certbot renew --dry-run
if [ $? -ne 0 ]; then
    echo "Certbot renewal test failed."
    exit 1
fi

# When we went through the process to install Nginx you may remember we created a php.info file in the /var/www/html directory. This was because this is the default document root that Nginx configures. However, we want a more manageable directory structure for our WordPress sites.
# Add server block so that NGINX can deal with request for the domain
mkdir -p ~/$SUB_DOMAIN/logs ~/$SUB_DOMAIN/public
chmod -R 755 ~/$SUB_DOMAIN


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
sudo ln -s /etc/nginx/sites-available/$SUB_DOMAIN /etc/nginx/sites-enabled/$SUB_DOMAIN
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