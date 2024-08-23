#!/bin/bash
# config.sh

# Export variables
export CNAME="ab" # This is CNAME name for the site, the prefix
export DOMAIN="seeingspinningspheres" # This is the domain name for the site
export TLD="xyz" # This is the top level domain for the site
export TITLE="Seeing Spinning Spheres Corporation" # This
export WP_EMAIL="bbrootbeer@gmail.com"
#####################################################
export WWWCNAME="www.$CNAME"
export SUB_DOMAIN="$CNAME.$DOMAIN.$TLD"
export WWW_SUB_DOMAIN="$WWWCNAME.$DOMAIN.$TLD"
export URL="https://$SUB_DOMAIN"
export WWW_URL="https://$WWW_SUB_DOMAIN"
