#!/bin/bash

read -p "please enter name and password of the file: " filename

# filename="empty.txt" # for Checking

checkEmpty=$(cat "$filename")
if [ ! -e "$filename" ]; then
    echo "File doesn't exist or is invalid."
elif [ ${#checkEmpty} -eq 0 ]; then
    echo "The provided file is empty1"
else
    while IFS= read -r line; do

    red='\033[31m'
    green='\033[0;32m'
    blue='\033[0;34m'
    white='\033[0m'

    totalChar=$(echo "$line" | wc -c)
    
    allowChar=$(echo "$line" | grep -o '[A-Z0-9#!._-]' | tr -d '\n')
    disAllowedChars=$(echo "$line" | grep -o '[^A-Z0-9#!._-]' | tr -d '\n')

    echo -e "${blue}${line}${white} [T: ${totalChar}] [A: ${green}${allowChar}${white} (${#allowChar})] [D: ${red}${disAllowedChars}${white} (${#disAllowedChars})]" 

done < "$filename"
fi

exit 0



