#!/bin/bash

# Function to check and delete a file or symbolic link
check_and_delete() {
    local file_path=$1
    if [ -e "$file_path" ]; then
        sudo rm "$file_path"
        echo "Deleted: $file_path"
    else
        echo "Warning: $file_path does not exist."
    fi
}

# List of files to check and delete
files_to_delete=(
    "/var/www/html/info.php"
    "/etc/nginx/sites-available/default"
    "/etc/nginx/sites-enabled/default"
)

# Iterate over the list and process each file
for file in "${files_to_delete[@]}"; do
    check_and_delete "$file"
done