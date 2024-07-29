#!/bin/bash

#Both arguments are provided or not
if [ $# -ne 2 ]; then
    echo "$1 or $2 is empty."
    exit 1
fi

filesdir="$1"
searchstr="$2"

#Filesdir exists and is a directory or not
if [ ! -d "$filesdir" ]; then
    echo "$filesdir is not a valid directory."
    exit 1
fi

#Return number of files in filesdir and its subdirectories
num_files=$(find "$filesdir" -type f | wc -l)

#Return matching lines in files
num_matching_lines=$(grep -r "$searchstr" "$filesdir" | wc -l)

echo "The number of files are $num_files and the number of matching lines are $num_matching_lines."
