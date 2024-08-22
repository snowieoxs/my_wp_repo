#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prompt for MySQL root password
read -sp "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
echo

# Install MySQL
sudo apt update -y
sudo apt install mysql-server -y

# Create a temporary MySQL init file with the environment variables substituted
envsubst < "$SCRIPT_DIR/mysql-init.sql" > "$SCRIPT_DIR/mysql-init-temp.sql"

# Secure MySQL
sudo mysqld --init-file="$SCRIPT_DIR/mysql-init-temp.sql" --skip-networking &

# Cleanup
rm "$SCRIPT_DIR/mysql-init-temp.sql"

echo "MySQL initialization and security complete."
