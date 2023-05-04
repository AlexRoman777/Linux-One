#!/bin/bash

# pdftosite - Generates a website from a PDF file
# Author: Alex Roman

# Used -zoom 0.75 to scale the output to 75% of the original size

checklist() {
    # This is used to check for all possible errors
    # Check if number of arguments is equal to 2
    if [ $# -ne 2 ]; then
        echo "Received $# arguments, expected 2"
        echo "It should be lile this: $0 <pdffile> <destination>"
        exit 1
    fi

    # Check if pdftohtml is installed
    if ! command -v pdftohtml &>/dev/null; then
        echo "pdftohtml could not be found"
        exit 1
    fi

    # Check if jpegtopnm is installed
    if ! command -v jpegtopnm &>/dev/null; then
        echo "jpegtopnm could not be found"
        exit 1
    fi

    # Check if pnmscale is installed
    if ! command -v pnmscale &>/dev/null; then
        echo "pnmscale could not be found"
        exit 1
    fi

    # Check if ppmtojpeg is installed
    if ! command -v ppmtojpeg &>/dev/null; then
        echo "ppmtojpeg could not be found"
        exit 1
    fi

    # Check if the destination folder exists
    if [ ! -d "$destination" ]; then
        echo "$destination does not exist"
        # Ask the user if they want to create the folder
        read -r -p "Do you want to create the folder? [Y/n] " createFolder
        if [[ $createFolder == "n" ]]; then
            exit 1
        fi
        # Create the folder
        if ! mkdir -p "$destination";
        then
            echo "Could not create $destination"
            exit 1
        fi
    fi

    # Check if the PDF file exists
    if [ ! -f "$pdfFile" ]; then
        echo "$pdfFile not found, please check the path"
        exit 1
    fi

    # Check if the PDF file is a PDF by checking the first 4 bytes, which should be %PDF
    pdfHeader="$(head -c 4 "$1")"
    if [ "$pdfHeader" != "%PDF" ]; then
        echo "$pdfFile is not a PDF file"
        exit 1
    fi

}

convertToHTML() {
    # Extract the PDF to an HTML site using pdftohtml
    # -q is for quiet mode
    # -c is for complex mode, -q is for quiet mode
    # -zoom 0.75 is for making the pages smaller, easyer for me to inspect on my laptop
    # -fmt jpg is for converting the images to JPG directly

    # Make the img directory
    mkdir -p "$destination/$imgDir"
    # Convert the PDF to HTML
    pdftohtml -q -fmt jpg -c -zoom 0.75 "$pdfFile" "$destination/$filePrefix"
}

moveAndConvertImages() {

    images=$(find "$destination" -name "*.jpg" -type f)

    for image in $images; do
        if [ -e "$image" ]; then
            originalName=$(basename "$image")
            # replace index with img
            newImgName=$(echo "$originalName" | sed -e "s/index/img/g")
            # Transform the image to grayscale and resize it to 600px
            jpegtopnm "$image" | pnmscale -xsize 600 | ppmtojpeg -grayscale >"$destination/$imgDir/$newImgName"
            # Remove the original image
            rm "$image"
        fi
    done
}

makeCSS() {
    # In case there is no CSS folder, create it
    if [ ! -d "$destination/css" ]; then
        mkdir -p "$destination/css"
    fi

    # Create the CSS file
    # Not of much use in our case but we will link it to the HTML files when we update them
    cat <<EOF >"$destination/css/main.css"
    body {
        font-family: Arial, Helvetica, sans-serif, "Open Sans", Verdana;
         }
EOF
}

updateHTML() {
    htmlFiles=$(find "$destination" -name "*.html" -type f)
    for htmlFile in $htmlFiles; do
        # Ignore index_ind.html, index-outline.html and index.html because they don't have image links
        if [[ $htmlFile == *"_ind.html" ]] || [[ $htmlFile == *"-outline.html" ]] || [[ $htmlFile == *"$filePrefix.html" ]]; then
            continue
        else
            # Replace the index with img in the image links in the HTML file
            sed -i 's|src="index|src="img/img|g' "$htmlFile"
            # Add the CSS link to the HTML file
            sed -i 's/<head>/<head>\n\t<link rel="stylesheet" href="css\/main.css">/g' "$htmlFile"
            # Add the author to the header, not needed but i had to mark my work somehow ;)
            sed -i 's/<head>/<head>\n\t<meta name="author" content="Alex Roman">/g' "$htmlFile"
        fi
    done
}

main() {

    pdfFile="$1"
    destination="$2"

    filePrefix='index'
    imgDir='img'

    checklist "$@"
    echo "  >>> Checklist passed!"

    convertToHTML
    echo "  >>> PDF converted to HTML!"

    moveAndConvertImages
    echo "  >>> Images converted and moved to img folder!"

    makeCSS
    echo "  >>> CSS file created!"

    updateHTML
    echo "  >>> HTML files updated!"
}

main "$@"
