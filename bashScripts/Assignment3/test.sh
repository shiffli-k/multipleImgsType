#!/bin/bash

getsize(){
    let mb=1048576
    let kb=1024
    if [[ $1 -ge $mb ]]; then
        # Converting bytes to Mb
        echo "$(echo $1 | awk '{printf "%.2f", $1/1024/1024}')Mb"
    elif [[ $1 -ge $kb ]]; then
        # Converting bytes to Kb
        echo "$(echo $1 | awk '{printf "%.2f", $1/1024}')Kb"
    else
        echo "$1b"
    fi
}

# What i need
file_size_custom=0
file_name=0
file_size=0
downloaded_file_size=0


DIRECTORY_NAME="images_2023-10-08_08-48-56"
file_list=$(du -b "$DIRECTORY_NAME"/* | sort -nr)

IFS=$'\n'
for each_line in $file_list; do
    FILE_NAME_WITH_PATH=$(echo "$each_line" | awk '{print $2}')
    FILE_SIZE_BYTES=$(echo "$each_line" | awk '{print $1}')
    file_size_custom=$(getsize "$FILE_SIZE_BYTES")
    file_name=$(basename "$FILE_NAME_WITH_PATH")
    echo -e "$file_name - $file_size_custom"
    downloaded_file_size=$((downloaded_file_size+FILE_SIZE_BYTES))
done

echo -e "Final Size $(getsize "$downloaded_file_size")"