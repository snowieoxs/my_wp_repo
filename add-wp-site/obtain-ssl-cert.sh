#!/bin/bash
# obtain-ssl-cert.sh

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Function to handle errors
handle_error() {
    echo "***********************************************************************************************************"
    echo "obtain-ssl-cert.sh Error on line $2: $1"
    exit 1
}

# Idk you are going to have to take a look at this, and mess around with cloud config
# sudo apt install software-properties-common
# sudo add-apt-repository universe

# Update system and install necessary packages
sudo apt update || handle_error "Failed to update package list." $LINENO
sudo apt install certbot python3-certbot-nginx || handle_error "Failed to install certbot and dependencies." $LINENO

# Obtain the SSL certificate
sudo certbot --nginx -d "$SUB_DOMAIN" -d "$WWW_SUB_DOMAIN" || handle_error "Failed to obtain SSL certificate." $LINENO

# Test automatic renewal process
sudo certbot renew --dry-run || handle_error "Failed to test automatic renewal process." $LINENO

# If the certbot renewal test passes, execute make-sites-available.sh
# MAKE_SITE_AVAILABLE_SCRIPT="$SCRIPT_DIR/make-site-available.sh"

# if [ -f "$MAKE_SITE_AVAILABLE_SCRIPT" ]; then
#     chmod +x "$MAKE_SITE_AVAILABLE_SCRIPT"
#     "$MAKE_SITE_AVAILABLE_SCRIPT" || handle_error "make-sites-available.sh script failed." $LINENO
# else
#     handle_error "make-sites-available.sh script not found." $LINENO
# fi

chmod +x "$SCRIPT_DIR/make-site-available.sh"
echo "obtain-ssl-cert.sh completed successfully."