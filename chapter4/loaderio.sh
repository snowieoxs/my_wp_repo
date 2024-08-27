#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the name of the script file
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
# Source the config file
source "$SCRIPT_DIR/config.sh"

# Function to handle errors
handle_error() {
    echo "***********************************************************************************************************"
    echo "$SCRIPT_NAME Error on line $2: $1"
    exit 1
}

# Ask for user input
read -p "Enter the content for the file: " FILE_CONTENT

# Strip spaces from the input
FILE_CONTENT="${FILE_CONTENT// /}"

# Navigate to the specified directory
TARGET_DIR=~/"$SUB_DOMAIN/public"
cd "$TARGET_DIR" || handle_error "Failed to change directory to $TARGET_DIR" $LINENO

# Create the file with the input content
FILE_NAME="${FILE_CONTENT}.txt"
echo "$FILE_CONTENT" > "$FILE_NAME" || handle_error "Failed to create file $FILE_NAME" $LINENO

chmod +x install-redis-object-cache.sh
echo "File $FILE_NAME created successfully in $TARGET_DIR with the content: $FILE_CONTENT"
echo "$SCRIPT_NAME script finished."