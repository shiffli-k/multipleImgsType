#!/bin/bash


awk '{ 



    # for calculating total
    totalcount = length($0);
    currentLine = $0;

    allowedCharacters = "";
    notAllowedChar="";


    for ( i=length(currentLine) ; i >= 1 ; i-- ) {
        if(substr(currentLine, i, 1) ~ /[A-Z0-9#!._-]/){
            allowedCharacters = allowedCharacters substr(currentLine, i, 1)
        }else{
            notAllowedChar = notAllowedChar substr(currentLine, i, 1)
        }
    }

    allowedCharcCount = length(allowedCharacters);
    Notallowcharcount = length(notAllowedChar);

    red = "\033[31m"
    green = "\033[0;32m"
    blue = "\033[0;34m"
    white = "\033[0m"

    print ( blue $0 white " [T: " totalcount "] [A: "green allowedCharacters white"  ("allowedCharcCount)")]" " [D: " red notAllowedChar white " (" Notallowcharcount ")]"


    }' Portfolio1.txt ;

