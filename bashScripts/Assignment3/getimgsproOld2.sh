#!/bin/bash

#08OCT2023

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
OPTERR="Argument(s) ${green}'-z -a -d'${white} are allowed! ${red}Script is exiting - Try again!${white}"
# Below if statment's condition checks if any arguments are passed
if [[ $# -gt 0 ]]; then
    # If True, using getopts check if option passed is z and store in otp
    while getopts "adz" opt; do
        # If z is passed, doZip is stored as true. Which is used later to zip files.
        # else, the message stored in OPTERR is displayed and script exits with code 1.
        case $opt in
            z) doZip=true;;
            a) downloadAllFlag=true;;
            d) organizeFolder=true;;
            *) echo -e "$OPTERR" && exit 1;;
        esac
    done
fi

if [[ $organizeFolder ]]; then
    if [[ $doZip || $downloadAllFlag ]]; then
        echo -e "The Argument -d cannot be paired with -z or -a\n\n---- Script Completed. Exiting ----\n"
        exit 1;
    fi
    echo -e "\n${green}---Please find below, List of Directories:---\n${white}"

    # List all directories in the current directory
    for dir in */; do
        if [ -d "$dir" ]; then
            echo "$dir"
        fi
    done

    echo -e "\n${green}---Enter directory to delete or type 'all' to delete all---${white}"
    read userInput

    if [[ $userInput == "all" ]]; then
        echo -e "\n${blue}Attempting to Remove ALL Directories!${white}"
        
        # Delete all directories in the current directory
        for dir in */; do
            if [ -d "$dir" ]; then
                rm -r "$dir"
            fi
        done
        
        echo -e "\n${red}All Directories deleted!${white}\n\n---- Script Completed. Exiting ----\n"
        exit 0;
    fi

    # Check if the user input matches a directory name and delete it
    if [ -d "$userInput" ]; then
        echo -e "${green}Attempting to Remove Directory:${white} $userInput"
        rm -r "$userInput"
        echo -e "\n${red}Directory: $userInput removed!${white}\n\n---- Script Completed. Exiting ----\n"
    else
        echo -e "\n${red}Directory: '$userInput' not found.${white}\n\n---- Script Completed. Exiting ----\n"
    fi

    exit 0;
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
read USER_INPUT

# The user is expected to enter URL and image format separated by comma, using awk $1 and $2 to store URL and imageFormat in separate variables.
# Also using tr, to convert the filetype entered by user to lower case. For e.g. the script will consider 'PNG' same as 'png'
user_entered_url=$(echo "$USER_INPUT" | awk '{print $1}')
user_entered_fileType=$(echo "$USER_INPUT" | awk '{print $2}')
user_entered_fileType=$(echo "$user_entered_fileType" | tr '[:upper:]' '[:lower:]')

if [[ $downloadAllFlag ]]; then
    echo -e "\nScript is Run with ${green}-a${white}. Downloading all allowed images: ${ALLOWED_IMG_CHARACTERS[*]}"
    user_entered_fileType="png"
fi

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
        if [[ ! $downloadAllFlag && $current_img_url == *.$user_entered_fileType ]]; then
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
        # if user runs the script with -a
        elif [[ $downloadAllFlag ]]; then
            for EACH_FILE_TYPE in "${ALLOWED_IMG_CHARACTERS[@]}"; do
                if [[ $current_img_url == *.$EACH_FILE_TYPE ]]; then
                    if [[ $current_img_url != http* && $current_img_url != //* ]]; then
                        current_img_url="$user_entered_url/$current_img_url"
                    fi

                    if [[ $current_img_url == //* ]]; then
                        current_img_url="https:$current_img_url"
                    fi

                    if [[ " ${downloaded_images_url[*]} " == *" $current_img_url "* ]]; then
                        ((counter_duplicate_images++))
                    else
                        curl -O "$current_img_url" -s
                        mv "$(basename "$current_img_url")" "$DIRECTORY_NAME"
                        downloaded_images_url+=("$current_img_url")
                        ((counter_unique_images++))
                    fi
                fi
            done
        fi 
    done
    #done <<< "$EXTRACTED_IMG_TAGS"
    # Above while block will be executed for each img tag in html page.

    # Using echo with -e escape sequence enable, alerting the user of unqiue and duplicate images count.
    # The path where unqiue images were downloaded.
    echo -e "\nFrom the URL $user_entered_url there were ${green}$counter_unique_images${white} Unique $user_entered_fileType type Images of which ${red}$counter_duplicate_images${white} were duplicate(s)\n"
    echo -e "Download is Complete! - ${green}$counter_unique_images Image(s)${white} are Downloaded and are stored in: ${blue}/$DIRECTORY_NAME\n${white}"

    # Updated Code

    file_list=$(du -b "$DIRECTORY_NAME"/* | sort -nr -k1)
    downloaded_file_size=0
    length_longest_file=0
    additional_padding=5

    for EACH_FILE_PATH in "$DIRECTORY_NAME"/*; do
        # Use parameter expansion to get the filename without the path
        EACH_FILE_NAME=$(basename "$EACH_FILE_PATH")
        CURRENT_FILE_LENGTH="${#EACH_FILE_NAME}"

        # Check if the current filename length is greater than the current maximum
        if [ "$CURRENT_FILE_LENGTH" -gt "$length_longest_file" ]; then
            length_longest_file="$CURRENT_FILE_LENGTH"
            # LONGEST_FILENAME="$EACH_FILE_NAME"
            # echo -e "Longest File name is $LONGEST_FILENAME with size of $length_longest_file"
        fi
    done

    printf "${blue}%-*s%s\n${white}" "$((length_longest_file + additional_padding))" "File Name" "File Size"

    IFS=$'\n'
    for each_line in $file_list; do
        FILE_NAME_WITH_PATH=$(echo "$each_line" | awk '{print $2}')
        FILE_SIZE_BYTES=$(echo "$each_line" | awk '{print $1}')
        file_size_custom=$(getsize "$FILE_SIZE_BYTES")
        file_name=$(basename "$FILE_NAME_WITH_PATH")
        printf "%-*s%s\n" "$((length_longest_file + additional_padding))" "$(basename "$file_name")" "$file_size_custom"
        downloaded_file_size=$((downloaded_file_size+FILE_SIZE_BYTES))
    done

    printf "${green}%-*s%s\n${white}" "$((length_longest_file + additional_padding))" "Total Size" "$(getsize "$downloaded_file_size")"

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
    echo -e "\n${red}Could not Identify Image File Type.${white} Type/Paste URL ${green}<space>${white} Image File Type.\n"
    echo -e "---- Script Completed. Exiting ----\n"
    exit 1

# The else block would be a case where user has entered a fileformat that is not accepted.
# In such case, alerting the user the message and exiting with exit code 2.
else
    echo -e "${red}\nThe Entered file type of: '$user_entered_fileType' is invalid.${white} Only '${ALLOWED_IMG_CHARACTERS[*]}' are allowed. Please try again.\n "
    echo -e "---- Script Completed. Exiting ----\n"
    exit 1
fi
