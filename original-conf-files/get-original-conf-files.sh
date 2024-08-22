#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp /etc/nginx/nginx.conf $SCRIPT_DIR
cp /etc/php/8.3/fpm/pool.d/www.conf $SCRIPT_DIR
cp /etc/php/8.3/fpm/php.ini $SCRIPT_DIR
cp /etc/nginx/sites-available/default $SCRIPT_DIR
