#!/bin/bash

#Both arguments are provided or not
if [ $# -ne 2 ]; then
    echo "$1 or $2 is empty."
    exit 1
fi

writefile="$1"
writestr="$2"

#Create the directory path if it doesn't exist
mkdir -p "$(dirname "$writefile")"

#Write the content to the file (overwriting if it exists)
echo "$writestr" > "$writefile" || { echo "Error creating $writefile"; exit 1; }

echo "File $writefile created successfully."
