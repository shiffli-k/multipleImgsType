#!/bin/bash
awk '{

    # For getting invalid characters
    invalidChar = $0;
    gsub("[A-Z0-9*#!._-]","",invalidChar);

    # For getting valid characters
    validChar = "";
    for (i = 1 ; i <= length($0) ; i++){
        if (substr($0, i, 1) ~ /[A-Z0-9*#!._-]/){
            validChar = validChar substr($0, i, 1);
        }
    }

    # For Reversing Valid Characters
    reverseValidChar = "";
    for (i = length($0); i>=1 ; i--){
        reverseValidChar = reverseValidChar substr(validChar, i, 1);
    }

    # For Reversing Invalid characters
    reversedInvalidChar = "";
    for (i = length(invalidChar); i>=1 ; i--){
        reversedInvalidChar = reversedInvalidChar substr(invalidChar, i, 1);
    }

    totalCharCount = length($0);
    allowedCharsCount = gsub("[A-Z0-9*#!._-]","&",$0);
    invalidCharsCount = totalCharCount - allowedCharsCount;
    
    print($0 " [T: " totalCharCount "] [A: "reverseValidChar" (" allowedCharsCount ")] [D: "reversedInvalidChar" (" invalidCharsCount ")]")

}' strlist1.txt