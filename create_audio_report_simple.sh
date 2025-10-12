#!/bin/bash

# This is a simplified script that extracts metadata from various audio files using exiftool.
# It takes two arguments: the source folder path and the target CSV file path.

# Function to display help message
display_help() {
    echo "Usage: $0 <source_folder> <target_csv_file>"
    echo
    echo "This script scans a source folder for audio files (mp3, m4a, amr, wav), extracts their metadata using exiftool,"
    echo "and generates a CSV file with the collected information."
    echo
    echo "Arguments:"
    echo "  source_folder      The mandatory path to the folder you want to scan."
    echo "  target_csv_file    The mandatory path where you want to save the output CSV file."
    echo
    echo "Options:"
    echo "  -h, --help         Display this help message and exit."
    echo
    echo "Dependencies:"
    echo "  This script requires 'exiftool' to be installed and available in your system's PATH."
}

# Check for help argument
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
    exit 0
fi

# Check for the correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Error: Invalid number of arguments."
    echo "Use -h or --help for usage information."
    exit 1
fi

SOURCE_FOLDER="$1"
TARGET_CSV="$2"

# Check if source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
    echo "Error: Source folder '$SOURCE_FOLDER' not found."
    exit 1
fi

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null
then
    echo "exiftool could not be found. Please install it first."
    exit
fi

echo "Scanning for audio files in '$SOURCE_FOLDER' and extracting metadata..."

temp_file=$(mktemp)

# Use exiftool to extract metadata, cleaning up the Comment field.
exiftool -m -r -charset UTF8 -ext mp3 -ext m4a -ext amr -ext wav -p '$FileName|$Directory|$FileSize#|${Album;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|$Year|$CreateDate|$Duration|${Artist;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|${Title;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|${Genre;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|${Comment;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}' "$SOURCE_FOLDER" > "$temp_file"

# Check if exiftool command was successful
if [ $? -ne 0 ]; then
    echo "Error: exiftool command failed. Aborting."
    rm "$temp_file"
    exit 1
fi

# Use awk to process the metadata and create the final CSV.
awk -v source_folder="$SOURCE_FOLDER" \
'BEGIN {
    FS="|";
    print "File Name,File Path,Size (MB),Album,Year,Duration,Artist,Title,Genre,Comment";
}
{
    # Make the file path relative to the source folder
    sub(source_folder, "", $2)

    # Album logic
    album = $4
    if (album == "") {
        # Get folder name from directory path
        split($2, parts, "/")
        album = parts[length(parts)]
        if (album == "") {
            album = "Root"
        }
    }

    # Year logic
    year = $5
    if (year == "" || year !~ /^[0-9]{4}$/) {
        # Get year from creation date if year tag is invalid
        if ($6 ~ /^[0-9]{4}/) {
            year = substr($6, 1, 4)
        } else {
            year = "N/A"
        }
    }
    # Ensure year is just YYYY from a date string
    if (year ~ /[0-9]{4}/) {
        match(year, /[0-9]{4}/)
        year = substr(year, RSTART, RLENGTH)
    }

    # Size
    size_mb = $3 / (1024*1024)

    # Print CSV line, with all text fields wrapped in double quotes.
    printf("\"%s\",\"%s\",%.2f,\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", $1, $2, size_mb, album, year, $7, $8, $9, $10, $11)

}' "$temp_file" > "$TARGET_CSV"

rm "$temp_file"

echo "Metadata extraction complete. The data is saved in '$TARGET_CSV'"