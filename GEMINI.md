# Project: Audio Metadata Extractor

## Project Overview

This project consists of a single shell script, `create_audio_report_simple.sh`, designed to extract metadata from audio files within a specified directory. It leverages the powerful `exiftool` command-line utility to read metadata from various audio formats (including `mp3`, `m4a`, `amr`, and `wav`) and generates a comprehensive CSV report.

The primary goal of this script is to provide a simple and effective way to catalog and manage large audio collections by extracting key information such as Title, Artist, Album, Year, and more.

### Key Technologies

*   **Shell Scripting (`bash`)**: The core logic is written as a `bash` script, making it portable across Unix-like systems (Linux, macOS).
*   **`exiftool`**: This is a critical dependency for reading and extracting metadata from the audio files.
*   **`awk`**: Used for processing the extracted metadata and formatting it into a CSV structure.

## Building and Running

This project does not require a build process. It can be run directly from the command line.

### Prerequisites

*   **`exiftool`**: You must have `exiftool` installed and available in your system's PATH. Instructions for installation are in the `README.md` file.

### Running the Script

To run the script, you need to provide two arguments: the source folder containing the audio files and the path for the output CSV file.

**Syntax:**

```bash
./create_audio_report_simple.sh <source_folder> <target_csv_file>
```

**Example:**

```bash
./create_audio_report_simple.sh ~/Music/Podcasts ./podcasts_metadata.csv
```

This command will scan the `~/Music/Podcasts` directory for audio files and create a CSV report named `podcasts_metadata.csv` in the current directory.

## Development Conventions

*   The script is written in `bash` and should be compatible with standard `bash` environments.
*   The script follows a simple procedural style.
*   Error handling is included for missing dependencies and incorrect arguments.
*   A temporary file is used to stage the `exiftool` output before it's processed by `awk`, which is a good practice for managing intermediate data.
