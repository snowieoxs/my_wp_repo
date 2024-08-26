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

echo "File $FILE_NAME created successfully in $TARGET_DIR with the content: $FILE_CONTENT"