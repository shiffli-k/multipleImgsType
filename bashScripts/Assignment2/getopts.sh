#!/bin/bash

#doZip=false
OPTERR="Only one argument '-z' is allowed! Script is exiting - Try again!"

if [[ $# -gt 0 ]]; then
    while getopts "z" opt; do
        case $opt in
            z) doZip=true;;
            *) echo -e "$OPTERR" && exit 1;;
        esac
    done
fi

if [[ $doZip ]]; then
    echo "ZIP!!!!"
fi


PATH="TEST"

for file in "$PATH"; do

    # The file variable will hold each file. Using -f to check if exists
    if [ -f "$file" ]; then
        
        # Using basename to get the filename without path
        file_name=$(basename "$file")
        # using du -h to get the size of file and using cut to remove filepath and get only filesize
        file_size=$(du -h "$file" | cut -f1)

        # Printing with colors the size with filename
        # Using same -50 to have 50 character left align padding
        printf "%-50s %s\n" "$file_name" "$file_size"
    fi
done