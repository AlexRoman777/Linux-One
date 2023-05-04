#!/bin/bash

# servepdf - Serves a PDF-file on a local webserver.
# Author: Alex Roman

validateArguments() {
    # Create local variables, so that they are only available in the function
    local numberOfArguments="$#" # Get the number of arguments
    local pdfFile="$1"
    local pdfFileValid="$(head -c 4 "$1")" # Check if file is a PDF by checking the first 4 bytes, which should be %PDF
    local portNumber="$2"

    if [[ $numberOfArguments -lt 1 || $numberOfArguments -gt 2 ]]; then
        echo "You have $numberOfArguments arguments, but you should have 2 arguments, PDF and port"
        echo 'Please follow the syntax: ./servepdf /path/to/pdf 9003'

        read -p "Do you want to continue, and reenter the arguments? [Y/n] " continue

        if [[ $continue == "n" ]]; then
            exit 1 # Exit the script
        fi

        read -p "Please enter the path to the PDF-file: " pdfFile # Ask the user to reenter the PDF-file
        read -p "Please enter the port you want to use, or press enter to use the default port 8000: " portNumber
        validateArguments "$pdfFile" "$portNumber" # Call the function again with the new arguments

    elif [[ $pdfFileValid != "%PDF" ]]; then # If the variable pdfFile is not equal to "%PDF", then it is not a PDF-file
        echo "$1 is not a PDF-file!"
        read -p "Do you want to continue and reenter the pdf-file? [Y/n] " continue
        if [[ $continue == "n" ]]; then
            exit 1
        fi
        read -p "Please enter the path to the PDF-file: " pdfFile
        validateArguments "$pdfFile" "$portNumber" # Call the function again with the new arguments

    elif [[ -z $portNumber ]]; then # If the variable portNumber is empty, then set the port to 8000
        port=8000
    elif [[ $portNumber -le 1024 || $portNumber -gt 65535 ]]; then
        echo "$portNumber is not a valid port! Please enter a port between 1024 and 65535"
        # Ask the user if he wants to continue and reenter the port or exit
        read -p "Do you want to continue and reenter the port? [Y/n] " continue
        if [[ $continue == "n" ]]; then
            exit 1
        fi
        read -p "Please enter the port you want to use, or press enter to use the default port 8000: " portNumber
        validateArguments "$1" "$portNumber" # Call the function again with the new arguments
    else
        port="$portNumber" # If the port is valid, then set the port to the portNumber
    fi
}

createTemporaryFolder() {
    temporaryFolder="/tmp/.temporary"              # Create a variable for the temporary folder
    serverLogFile="$temporaryFolder/webserver.log" # Create a variable for the log file

    if [[ -d "$temporaryFolder" ]]; then # If the temporary folder exists, then remove it
        rm -r "$temporaryFolder"
    fi

    mkdir -p "$temporaryFolder" && chmod 700 "$temporaryFolder"

}

# Check if the pdftofile script is present, just to be sure
checkIfPdftoSiteIsPresent() {
    if [ ! -f pdftosite ]; then
        echo "pdftosite script not found!"
        exit 1
    fi
}

# Convert the PDF-file to a website
convertPdfToWebsite() {
    echo "Converting... In progress!"
    ./pdftosite "$1" "$temporaryFolder" >/dev/null 2>&1
    # Check if the conversion was successful
    if [[ $? -ne 0 ]]; then # If the exit code is not 0, then the conversion was not successful
        echo "The conversion was not successful"
        exit 1
    else
        echo "Converting... Done!"
    fi
}

# Copy the converted website to the final folder
copyConvertedWebsite() {
    baseNameOfPdfFile="$(basename "$1" .pdf)" # Get the basename of the pdfFile
    # If the conversion was successful, by checking if the temporary folder is empty
    if [[ -z "$(ls -A "$temporaryFolder")" ]]; then
        echo "There are no files in the temporary folder"
        exit 1
    fi

    # Make a hidden folder in the tmp folder, so that the user can't see it
    mkdir -p "$HOME/.project2/$baseNameOfPdfFile"

    # Copy the files from the temporary folder to the final folder
    cp -r "$temporaryFolder"/* "$HOME/.project2/$baseNameOfPdfFile"
}

# Start the python http server
startPythonHttpServer() {
    echo "Starting the webserver on port $port"
    # Start the python http server on the specified port and send the output to the log file
    python3 -mhttp.server "$port" --directory "$temporaryFolder" >"$serverLogFile"
}

# Create the main function
main() {
    validateArguments "$@"
    # echo "Valid arguments!"
    createTemporaryFolder
    # echo "Temporary folder created!"
    checkIfPdftoSiteIsPresent
    # echo "pdftosite script found!"
    convertPdfToWebsite "$1"
    # echo "PDF converted to website!"
    copyConvertedWebsite "$1"
    # echo "Website copied to the final folder!"
    startPythonHttpServer
    # echo "Googbye!"
}

# Call the main function
main "$@"
