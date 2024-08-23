#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install MySQL
sudo apt update -y
sudo apt install mysql-server -y

# Prompt for MySQL root password
read -sp "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
echo

# Export the MySQL root password as an environment variable
export MYSQL_ROOT_PASSWORD

# Create a temporary MySQL init file with the environment variables substituted
MYSQL_INIT_TEMP_FILE=$(mktemp)
envsubst < "$SCRIPT_DIR/mysql-init.sql" > "$MYSQL_INIT_TEMP_FILE"

# Secure MySQL
sudo mysqld --init-file="$MYSQL_INIT_TEMP_FILE" --skip-networking &

# Wait for MySQL to finish initialization
wait

# Cleanup
rm "$MYSQL_INIT_TEMP_FILE"

echo "MySQL initialization and security complete."