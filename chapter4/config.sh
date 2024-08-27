#!/bin/bash
# config.sh

# Export variables
export CNAME="test" # This is CNAME name for the site, the prefix
export DOMAIN="seeingspinningspheres" # This is the domain name for the site
export TLD="xyz" # This is the top level domain for the site
export TITLE="Seeing Spinning Spheres Forever" # This
export WP_EMAIL="bbrootbeer@gmail.com"
#####################################################
export USERNAME="$USER" # Use the current user's username
export WWWCNAME="www.$CNAME"
export SUB_DOMAIN="$CNAME.$DOMAIN.$TLD"
export WWW_SUB_DOMAIN="$WWWCNAME.$DOMAIN.$TLD"
export URL="https://$SUB_DOMAIN"
export WWW_URL="https://$WWW_SUB_DOMAIN"


#########################################################

# Define your variables
ulimit_n=$(ulimit -n)
num_cores=$(grep -c processor /proc/cpuinfo)
utilization_factor=0.90

# Calculate worker_connections
worker_connections=$(echo "$ulimit_n * $num_cores * $utilization_factor" | bc)
worker_connections=$(printf "%.0f" $worker_connections)  # Round to the nearest integer

# Export variables
export NGINX_USER="$USER" # This was originally set to "www-data"
export WORKER_PROCESSES=$num_cores # This was originally set to "auto"
export WORKER_CONNECTIONS=$worker_connections # This was originally set to "768"
export MULTI_ACCEPT="on" # This was originally commented out, presumably off
export KEEPALIVE_TIMEOUT="15" # This was originally blank"
export SERVER_TOKENS="off" # Originally commented out
export CLIENT_MAX_BODY_SIZE="64m" # Originally blank
export GZIP_PROXIED="any" # Originally commented out
export GZIP_COMP_LEVEL="5" # Originally set to 6
export GZIP_TYPES="text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript"

