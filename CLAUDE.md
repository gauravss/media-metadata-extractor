# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a single-file bash utility (`create_audio_report_simple.sh`) that scans directories for audio files (mp3, m4a, amr, wav, flac, ogg, opus, aac, wma), extracts metadata via `exiftool`, and outputs a CSV report. There is no build system.

## Running the Script

```bash
./create_audio_report_simple.sh [--dry-run] <source_folder> [<target_csv_file>]
```

`--dry-run` lists matching files and exits without writing a CSV (target not required).

**Prerequisite:** `exiftool` must be installed (`brew install exiftool` on macOS).

## Architecture

The script is structured in three sequential phases:

1. **Validation** — checks args, source folder existence, target CSV parent directory existence, and `exiftool` availability.
2. **Data collection** — uses `find -print0` with a null-delimited `while IFS= read -r -d ''` loop to safely handle filenames with spaces or special characters. For each file, runs `md5cmd` (a shim that selects `md5 -q` on macOS or `md5sum` on Linux) for the checksum, and `exiftool` with a pipe-delimited format string. Sanitization (strip `\n`/`\r`, trim/collapse whitespace) happens inline within the `exiftool -p` format string. Results are appended to a `mktemp` temp file.
3. **CSV generation** — `awk` reads the pipe-delimited temp file, applies fallback logic (folder name → Album if empty; CreateDate year → Year if tag missing/invalid), converts byte sizes to MB, escapes double quotes by doubling, and writes the final CSV.

The `exiftool` format string extracts these fields in order (pipe-separated):
`FileName | Directory | FileSize# | Album | Year | CreateDate | Duration | Artist | Title | Genre | Comment`
Then `md5_checksum` is appended as field 12.

## Key Behaviors to Preserve

- **Album fallback**: if `$Album` is empty, use the last component of the directory path; if that's also empty, use `"Root"`.
- **Year fallback**: if `$Year` is not a 4-digit number, extract the first 4 digits from `$CreateDate`; otherwise `"N/A"`.
- **CSV quoting**: all text fields (including `Duration`) are wrapped in `"..."` and internal quotes are doubled (`"` → `""`). Only `Checksum` (`$12`, a hex string) is printed without quotes.
- **Temp file cleanup**: `trap 'rm -f "$temp_file"' EXIT` ensures cleanup even on error.

## GitHub Actions (CI/CD)

The `.github/workflows/` directory contains Gemini CLI-powered automations:
- **`gemini-dispatch.yml`** — event router for PRs, issues, and comments; dispatches to review/triage/invoke workflows.
- **`gemini-review.yml`** — automated PR code review with severity-labeled inline comments.
- **`gemini-invoke.yml`** — task automation requiring human approval before executing file changes.
- **`gemini-triage.yml`** / **`gemini-scheduled-triage.yml`** — issue labeling and classification.
