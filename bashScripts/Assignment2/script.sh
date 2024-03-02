#!/bin/bash

# Name : Aadavan Sridhar
# Student id : 10630319

# Script for - Assignment 2.1: Portfolio 2 

# ---- Summary of Script ----
# The script will prompt user for a url with image type. 
# The script also accepts a argument -z, when passed will zip all the images the script downloads. 
# Script will process webpages containing absolute path and relative path. ‘-z’ validation is done using getopts. 
# Script validates if user entered image type is of jpg, jpeg, gif, png. 
# Appropriate error message is displayed when users enters URL without image type or URL with invalid image type. 
# If Image type is valid, the script creates directory to store the images. 
# Using Curl the HTML is fetched and using grep with regular expression the image tag’s src= is obtained. 
# Every tag’s src is checked to see if it contains the image type entered by the user. 
# Using Curl -O, images are downloaded and moved with mv. 
# Image names are stored in array for duplication check.
# Counter for Unique and Duplicate images is present. 
# Process is repeated for every image tag. 
# Data from the counter variables are print to the user with path. 
# Using du -b and printf statements a table of image filenames and their size is displayed. 
# The getsize method will calculate and return the precise size from bytes to KB or MB. 
# If user runs the script with -z, using ZIP the images in directory are zipped to a single zip file.

# Defining Color constatns to be used with echo command.
red='\033[31m'
green='\033[0;32m'
blue='\033[0;34m'
white='\033[0m'

# Using echo, printing the start of script execution.
echo -e "\n---- Script execution Started ----\n"

# Below Code block will look for arguments passed while executing script and checks if only -z is allowed. 
# Any other -arguments are not allowed and responds with error message OPTERR.
# Storying the error message for getopts
OPTERR="Only one argument ${green}'-z'${white} is allowed! ${red}Script is exiting - Try again!${white}"
# Below if statment's condition checks if any arguments are passed
if [[ $# -gt 0 ]]; then
    # If True, using getopts check if option passed is z and store in otp
    while getopts "z" opt; do
        # If z is passed, doZip is stored as true. Which is used later to zip files.
        # else, the message stored in OPTERR is displayed and script exits with code 1.
        case $opt in
            z) doZip=true;;
            *) echo -e "$OPTERR" && exit 1;;
        esac
    done
fi


#Below are list of Constants that will be used across the script.
# -ALLOWED_IMG_CHARACTERS is an Array of string that stores all allowed image file types
ALLOWED_IMG_CHARACTERS=("jpg" "jpeg" "gif" "png")
# -TIMESTAMP_FOR_DIRECTORY_NAME stores current date with time used later for DirectoryName & Zip File Name
# -DIRECTORY_NAME will hold the final name for images Directory.
# -ZIPFILE_NAME will hold the final name for Zip File.
# Since the filename/Directory uses current date/time, there are no chance of directory/zip file overlapping when executing the script multiple times. 
TIMESTAMP_FOR_DIRECTORY_NAME=$(date +"%Y-%m-%d_%H-%M-%S")
DIRECTORY_NAME="images_$TIMESTAMP_FOR_DIRECTORY_NAME"
ZIPFILE_NAME="$DIRECTORY_NAME/Zipped$DIRECTORY_NAME.zip"

# Declaring variables:
# -downloaded_images_url will hold the list of images that are stored, this is so that we can check if there are duplicate images.
downloaded_images_url=()
# -counter_duplicate_images -counter_unique_images will count every Unique and duplicate images
counter_duplicate_images=0
counter_unique_images=0

# Creating a function that converts and returns filesize from bytes to KB to MB.
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

# Alerting the user before promptign the user for URL along with image file format.
# Using read command to store URL and Image Format in USER_INPUT
echo -e -n "Note: Only ${ALLOWED_IMG_CHARACTERS[*]} img types are allowed\n\nEnter URL with a Image type separated by a space: "
read -r USER_INPUT

# The user is expected to enter URL and image format separated by comma, using awk $1 and $2 to store URL and imageFormat in separate variables.
# Also using tr, to convert the filetype entered by user to lower case. For e.g. the script will consider 'PNG' same as 'png'
user_entered_url=$(echo "$USER_INPUT" | awk '{print $1}')
user_entered_fileType=$(echo "$USER_INPUT" | awk '{print $2}')
user_entered_fileType=$(echo "$user_entered_fileType" | tr '[:upper:]' '[:lower:]')

# Checking if User entered file type is valid, comparing with Array ALLOWED_IMG_CHARACTERS containing the valid image formats.
if [[ " ${ALLOWED_IMG_CHARACTERS[*]} " == *" $user_entered_fileType "* ]]; then
    # The entered image format is valid. Proceeding with the script logic.

    # Creating directory to store all the images that will be downloaded.
    mkdir -p "$DIRECTORY_NAME"
    
    # Using CURL to get the contents of the HTML content using the URL entered by the user.
    # the -s is used to 'silence' the command, preventing to write logs in console.
    # -URL_HTML_CONTENT will store HTML page contents that contans the <img> tags that has image path.
    URL_HTML_CONTENT=$(curl -s "$user_entered_url")

    # -EXTRACTED_IMG_TAGS will hold all the <img> tags from the HTML page content
    # Using Echo which pipes into a grep that returns only the <img> tags
    # using -E in grep to extend Regular expression and -o to Only Matching the mentioned regular expression
    EXTRACTED_IMG_TAGS=$(echo "$URL_HTML_CONTENT" | grep -Eo '<img[^>]+>')

    # The EXTRACTED_IMG_TAGS variable will hold a list of all img tags.
    # Using While loop and read -r revursion, the inside block will be excuted for each img tag.
    #while read -r CURRENT_IMG_TAG; do
    for CURRENT_IMG_TAG in $EXTRACTED_IMG_TAGS; do

        # Following HTML Syntax, the <img> tag contains a "src=" argument where the Relative/Absolute path of image is located.
        # -CURRENT_IMG_TAG will hold current image tagt that is processing.
        # Usign echo which pipes into a regular expression '-only matching -Extend RegEx' to get the contents of src="" and using sed to remove slashes and 'src=' text.
        # The resulting -current_img_url will hold either Absolute or Relative path of image
        current_img_url=$(echo "$CURRENT_IMG_TAG" | grep -oE 'src="[^"]+"' | sed 's/src="//' | sed 's/"//')
        
        # Using a if block to check if current url from <img> tag matches with format entered by the user.
        # -current_img_url holds the current img path, checking with *.user_entered_fileType
        # *.user_entered_fileType where * is anything but ends with '.' and user entered file name
        if [[ $current_img_url == *.$user_entered_fileType ]]; then
            # Enters block if current image matches with user entered one.
            
            # Below echo command is for testing
            #echo "MATCHED URL: $current_img_url" 

            # Below two If statements checks a situation on how HTML <img> tags are handled.
            # If <img> type is relative:
            # Checking if img path is relative by checkign if img path starts with http.
            if [[ $current_img_url != http* && $current_img_url != //* ]]; then
                # Since the image path is relative, appending user entered url with image path to get complete url. 
                current_img_url="$user_entered_url/$current_img_url"
            fi

            # if <img> type is absolute but doesnt have http at the start.
            # For websites like Wikipedia, the img tag contained absolute path but without the http in url.
            if [[ $current_img_url == //* ]]; then
                # Appending https to the image path to make it a valid absolute url .
                current_img_url="https:$current_img_url"
            fi

            # Before downloading and storing current image, checking if its duplicate.
            # -downloaded_images_url contains already downloaded images, checking if current image is present in the array.
            if [[ " ${downloaded_images_url[*]} " == *" $current_img_url "* ]]; then
                # Belo code is for testing
                #echo "Found Duplicate Image"

                # Incrementing counter to alert the user later for the count of duplicate images. 
                ((counter_duplicate_images++))
            else
                # Below code is for testing

                # echo "Downloading From: $current_img_url"
                # echo "---------------------------------"

                # Using Curl command with -O to return output and with -s for silents which prevents curl to print to console.
                curl -O "$current_img_url" -s
                # using MV to store the image file into directory path 'DIRECTORY_NAME' created at the start of the script.
                # basename argument will only consider filename.
                mv "$(basename "$current_img_url")" "$DIRECTORY_NAME"

                # Once downloaded, storing img path in 'downloaded_images_url' so that it can be used to check for duplicate images.
                downloaded_images_url+=("$current_img_url")
                
                # Incrementing counter to alert the user later for the count of unique images. 
                ((counter_unique_images++))
            fi
        fi 
    done
    #done <<< "$EXTRACTED_IMG_TAGS"
    # Above while block will be executed for each img tag in html page.

    # Using echo with -e escape sequence enable, alerting the user of unqiue and duplicate images count.
    # The path where unqiue images were downloaded.
    echo -e "\nFrom the URL $user_entered_url there were ${green}$counter_unique_images${white} Unique $user_entered_fileType type Images of which ${red}$counter_duplicate_images${white} were duplicate(s)\n"
    echo -e "Download is Complete! - ${green}$counter_unique_images Image(s)${white} are Downloaded and are stored in: ${blue}/$DIRECTORY_NAME\n${white}"

    # Displaying users the list of files with their corresponding size.
    # Below line is for the header - displaying filename and its size.
    # Using c type printf statemets for a change to display the header.
    # %s is like a formatspecifier string to print a string 'File Name'
    # the -50 is used, where 50 represents the character minimum padding with - denoting left padding.
    # Using \n to create a new line.
    printf "${blue}%-50s | %-5s\n${white}" "File Name" "File Size(KiloBytes)"

    # Using a for loop to read every file in directory /*
    for file in "$DIRECTORY_NAME"/*; do

        # The file variable will hold each file. Using -f to check if exists
        if [ -f "$file" ]; then
            
            # Using basename to get the filename without path
            file_name=$(basename "$file")
            # using du -h to get the size of file and using cut to remove filepath and get only filesize
            #file_size=$(du -h "$file" | cut -f1)
            file_size=$(getsize "$(du -b "$file" | cut -f 1)")

            # Printing with colors the size with filename
            # Using same -50 to have 50 character left align padding
            printf "%-50s | %-5s\n" "$file_name" "$file_size"
        fi
    done

    #
    # Checking if doZip is true or false based on if argument -z is passed.
    if [[ $doZip ]]; then
        # if true, printing ZIP is inprogress.
        # Using zip command with -r to recursively do all files/folder in directory.
        # Zip command is also run with -q --quit so additional message is not displayed.
        echo -e "\n${blue}Script executed with -z${white} | Zipping in progress...."
        zip -rq "$ZIPFILE_NAME" "$DIRECTORY_NAME"
        echo -e "\n${green}Zipped successfully! ${white}Please find file at: ${green}/$ZIPFILE_NAME${white}"
    else
        # if User did not run the scipt with -z, printing message saying -z is a argument that exists.
        echo -e "\nOptional: Try running the script with '-z' to Zip the images!"
    fi
    
    # Printing that Scipt execution is ended
    # Exiting script with success code 0
    echo -e "\n---- Script Completed. Exiting ----\n"
    exit 0


# If the user entered file type is not same as the ALLOWED_IMG_CHARACTERS, there are two ways the script will exit
# If the user forgot to enter file Type: Using -z to check if enter file type is empty.
# When empty, alerting the user the message and exiting with exit code 2.
elif [[ -z "$user_entered_fileType" ]]; then
    echo -e "\n${red}Could not Identify Image File Type.${white} Type/Paste URL <space> Image File Type.\n"
    echo -e "---- Script Completed. Exiting ----\n"
    exit 1

# The else block would be a case where user has entered a fileformat that is not accepted.
# In such case, alerting the user the message and exiting with exit code 2.
else
    echo -e "${red}\nThe Entered file type of: '$user_entered_fileType' is invalid.${white} Only '${ALLOWED_IMG_CHARACTERS[*]}' are allowed. Please try again.\n "
    echo -e "---- Script Completed. Exiting ----\n"
    exit 1
fi