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

# Check if target CSV's parent directory exists
TARGET_DIR=$(dirname "$TARGET_CSV")
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null
then
    echo "exiftool could not be found. Please install it first."
    exit 1
fi

echo "Scanning for audio files in '$SOURCE_FOLDER' and extracting metadata..."

temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Determine md5 command for cross-platform compatibility (macOS vs Linux)
if command -v md5 &>/dev/null; then
    md5cmd() { md5 -q "$1"; }
else
    md5cmd() { md5sum "$1" | awk '{print $1}'; }
fi

# Find all audio files and loop through them (null-delimited to handle filenames with spaces/newlines)
while IFS= read -r -d '' file; do
    # Calculate MD5 checksum
    md5_checksum=$(md5cmd "$file")

    # Extract metadata with exiftool
    if ! exiftool_output=$(exiftool -m -charset UTF8 -p '$FileName|$Directory|$FileSize#|${Album;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|$Year|$CreateDate|$Duration|${Artist;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|${Title;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|${Genre;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}|${Comment;s/[\n\r]/ /g; s/^\s+//; s/\s+$//; s/\s+/ /g}' "$file" 2>/dev/null); then
        echo "Warning: skipping '$file' — exiftool failed to read metadata." >&2
        continue
    fi

    # Combine and write to temp file
    echo "$exiftool_output|$md5_checksum" >> "$temp_file"
done < <(find "$SOURCE_FOLDER" -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.amr" -o -iname "*.wav" \) -print0)

# Check if any files were found and processed
if [ ! -s "$temp_file" ]; then
    echo "No audio files found in the source folder."
    rm "$temp_file"
    exit 0
fi

# Use awk to process the metadata and create the final CSV.
awk -v source_folder="$SOURCE_FOLDER" \
'function escape(str) {
    gsub(/"/, "\"\"", str)
    return str
}
BEGIN {
    FS="|";
    print "File Name,File Path,Size (MB),Album,Year,Duration,Artist,Title,Genre,Comment,Checksum";
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
    printf("\"%s\",\"%s\",%.2f,\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", escape($1), escape($2), size_mb, escape(album), escape(year), escape($7), escape($8), escape($9), escape($10), escape($11), $12)

}' "$temp_file" > "$TARGET_CSV"

rm "$temp_file"

echo "Metadata extraction complete. The data is saved in '$TARGET_CSV'"