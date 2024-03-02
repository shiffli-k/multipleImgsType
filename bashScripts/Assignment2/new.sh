#!/bin/bash

if [[ -n "$1" ]] &&  [[ $1 != "-z" ]]; then
    echo "Invalid Argument"
    exit 3
fi

echo "SHEBANG!"

if [[ $1 == "-z" ]]; then
    echo "Images are Zipped at: "
else
    echo "Try running the script with '-z' to Zip the images!"
fi
exit 0
