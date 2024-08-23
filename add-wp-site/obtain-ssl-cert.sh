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
sudo certbot --nginx -d "$SUB_DOMAIN" -d "$WWW_SUB_DOMAIN"
if [ $? -ne 0 ]; then
    echo "Failed to obtain SSL certificate."
    exit 1
fi

# Take note of where the cert is saved because you will need it later
# Successfully received certificate.
# Certificate is saved at: /etc/letsencrypt/live/globex.turnipjuice.media/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/globex.turnipjuice.media/privkey.pem

# Test automatic renewal process
sudo certbot renew --dry-run
if [ $? -ne 0 ]; then
    echo "Certbot renewal test failed."
    exit 1
fi

# If the certbot renewal test passes, execute make-sites-available.sh
MAKE_SITES_AVAILABLE_SCRIPT="$SCRIPT_DIR/make-sites-available.sh"

if [ -f "$MAKE_SITES_AVAILABLE_SCRIPT" ]; then
    chmod +x "$MAKE_SITES_AVAILABLE_SCRIPT"
    "$MAKE_SITES_AVAILABLE_SCRIPT"
    if [ $? -ne 0 ]; then
        echo "make-sites-available.sh script failed."
        exit 1
    fi
else
    echo "make-sites-available.sh script not found."
    exit 1
fi

echo "make-sites-available.sh executed successfully."