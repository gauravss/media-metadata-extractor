# Media Metadata Extractor

This script extracts metadata from audio files in a specified directory and generates a CSV report.

## Description

The `create_audio_report_simple.sh` script scans a source folder for audio files (specifically `mp3`, `m4a`, `amr`, and `wav` formats), extracts their metadata, and organizes it into a CSV file. This is useful for cataloging and managing large collections of audio files.

The script extracts the following metadata fields:

- File Name
- File Path
- Size (in MB)
- Album
- Year
- Duration
- Artist
- Title
- Genre
- Comment

## Prerequisites

Before running this script, you need to have **ExifTool** installed on your system. ExifTool is a command-line application for reading, writing, and editing meta information in a wide variety of files.

### Installation

- **macOS**:
  - Using [Homebrew](https://brew.sh/):

    ```bash
    brew install exiftool
    ```

- **Windows**:
  - Download the ExifTool executable from the [ExifTool website](https://exiftool.org/).
  - Rename the executable to `exiftool.exe` and place it in your `C:\Windows` directory or any other directory in your system's PATH.

- **Linux (Debian/Ubuntu)**:

  ```bash
  sudo apt-get update
  sudo apt-get install libimage-exiftool-perl
  ```

To verify the installation, open a terminal or command prompt and run:

```bash
exiftool -ver
```

This should display the installed version number of ExifTool.

## Usage

Before running the script, you may need to make it executable:

```bash
chmod +x create_audio_report_simple.sh
```

The script requires two arguments: the path to the source folder containing the audio files and the path for the output CSV file.

### Syntax

```bash
./create_audio_report_simple.sh <source_folder> <target_csv_file>
```

### Arguments

- `source_folder`: The path to the directory containing the audio files you want to scan.
- `target_csv_file`: The full path where the output CSV report will be saved.

### Options

- `-h`, `--help`: Display a help message with usage instructions and exit.

### Examples

1. **Basic Usage**:
   To scan a folder named `MyMusic` located in your home directory and save the report as `audio_report.csv` on your desktop:

   ```bash
   ./create_audio_report_simple.sh ~/MyMusic ~/Desktop/audio_report.csv
   ```

2. **Scanning a Folder with Spaces in the Path**:
   If the path to your source folder or target file contains spaces, make sure to enclose the path in double quotes:

   ```bash
   ./create_audio_report_simple.sh "/Volumes/External Drive/My Audio Files" "report.csv"
   ```

3. **Getting Help**:
   To see the help message with details on how to use the script:

   ```bash
   ./create_audio_report_simple.sh --help
   ```

## Output

The script will generate a CSV file with the specified name and at the specified location. The CSV file will have the following columns:

- `File Name`
- `File Path`
- `Size (MB)`
- `Album`
- `Year`
- `Duration`
- `Artist`
- `Title`
- `Genre`
- `Comment`
