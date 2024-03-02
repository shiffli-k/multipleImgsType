#!/bin/bash

# Full Name  : Aadavan Sridhar
# Student id : 10630319


# The following Bash script serves Assignment 2.1: Portfolio 1. It processes a user-provided file's content, analysing each line's total character count, allowed and disallowed characters, and their respective counts. This data is then presented in a formatted manner.

# The script starts by requesting the user to specify a filename within the active directory. It reads the file's content using cat and stores it in checkEmpty.

# Next, it verifies the file's existence and validity. If the file is non-existent, an appropriate message is shown. If it exists, the script checks if the content is empty. If empty, a relevant message is displayed.

# If content is present, the script enters a loop to process each line:
# Colour codes are defined for output formatting.
# The line's total character count is calculated.
# Allowed and disallowed characters (uppercase letters, digits, specific special characters) are extracted using grep and regular expression, with their counts calculated separately.
# The reversed order of allowed and disallowed characters is generated using for loop and looping from last character to first.
# A formatted line is outputted, showcasing the line's content, total character count, reversed allowed characters, and reversed disallowed characters, with appropriate colours.
# Upon processing all lines, the script exits with code 0. 



read -p "Enter the name of the candidate password file (including ext): " filename  # Prompts the user for Filename

#filename="strlist.txt" # for testing

checkEmpty=$(cat "$filename") # Using cat reading the contents of the file and storing in checkEmpty, so it can be checked later if the content is zero.

if [ ! -e "$filename" ]; then # Checking if the file does not exists using -e and Not operator
    echo "File doesn't exist or is invalid." # If file doesnt exist then printing message that file doesnt exist.
elif [ ${#checkEmpty} -eq 0 ]; then # Checking if the length/size of file is 0 - meaning file is empty
    echo "The provided file is empty!" # Printing error to user that file is empty.
else # If File Exisits and is not empty, proceeding to get the required details.
    while IFS= read -r CurrentLine || [[ -n "$CurrentLine" ]]; do #Using While loop which will iterate from file that is read by 'read -r' command and with Internal File separator, each line of the file is stored in 'CurrentLine'. Or in cases where the last line of the file does not contain EOL(End Of Line) character, using Conditional Expression [[ ]] with -n (Ignore New Line / EOL) to read the last line of file.

        # Storing colors in variables which will be used later for printing output.
        red='\033[31m'
        green='\033[0;32m'
        blue='\033[0;34m'
        white='\033[0m'

        #totalChar=$(echo "$CurrentLine" | wc -c) 
        totalChar=$(echo "$CurrentLine" | tr -d '\n' | wc -c) #Storing count of characters in current line using wordcount(wc) and (-c) Count Characters. Using tr -d '\n' to remove EOL - End of Line Character before counting.
        
        # Using Regular expression [A-Z0-9#!._-] to solve the Assignment Criteria of extracting Allowed characters that matches 1. UpperCase 2. Numbers 3. Special Characters (*#!._-)
        allowChar=$(echo "$CurrentLine" | grep -o '[A-Z0-9#!._-]' | tr -d '\n')  # Storing characters from current line that matches the regular expression. Adding tr -d '\n', so to remove all the new line characters that are created from the grep command.
        disAllowedChars=$(echo "$CurrentLine" | grep -o '[^A-Z0-9#!._-]' | tr -d '\n') # Storing all disallowed characters by using the same logic as above but with slightly modified regular expression. Using ^ as a NOT operator to get all disallowed characters.

        revAllowChar="" # Creating a empty variable to store the reverse of allowed characters
        for (( i=${#CurrentLine}-1; i>=0; i-- )); do # Created a loop which starts from the last character of current line using its length and iterating untill first character is reached.
            revAllowChar="$revAllowChar${allowChar:$i:1}" # The loop will iterate from last character position to first character position, the character at i is stored in revAllowChar.
        done # Marking the end of for loop.

        revDisAllowedChars="" # Same as above, creating a variable that will store reversed disallowed characters.
        for (( i=${#CurrentLine}-1; i>=0; i-- )); do # Same as above, looping from last character of current line to the first.
            revDisAllowedChars="$revDisAllowedChars${disAllowedChars:$i:1}" # Same as above, getting the character at positon i and storring in variable revDisAllowedChars
        done # marking end of loop.

        # Below code prints the expected output of Characters of each line, total count, allowed , disallowed characters and its count with appropriate colours.
        # Using previously declare color code to print with color and using white to reset the color back to white.
        # Using #revAllowChar and #revDisAllowedChars to get the count of allowed and disallowed characters.
        echo -e "${blue}${CurrentLine}${white} [T: ${totalChar}] [A: ${green}${revAllowChar}${white} (${#revAllowChar})] [D: ${red}${revDisAllowedChars}${white} (${#revDisAllowedChars})]" 

    done < "$filename" # Marking end of while loop. This will be iterated untill end of file. Also filename entered by user is passed here.
fi # Marking end of if statement.

exit 0 # Marking end of script.