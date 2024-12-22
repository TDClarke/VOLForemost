#!/bin/bash

#Configuration variables
memory_dump="itest.mem"
process_to_extract="firefox.exe"
file_type_to_extract="jpg"
extracted_dir="extracted"

# Check for required tools
if ! command -v python &>/dev/null; then
    echo "Error: Python is not installed or not in the PATH."
    exit 1
fi

if ! [[ -f "foremost.exe" ]]; then
    echo "Error: 'foremost.exe' is missing in the current directory."
    exit 1
fi

# Extract process PIDs from the memory dump
echo "Extracting PIDs for process: $process_to_extract"
readarray -t processes < <(python vol.py -f "$memory_dump" windows.pslist.PsList 2>/dev/null | grep "$process_to_extract" | cut -d $'\t' -f 1)

# Check if any PIDs were found
if [ ${#processes[@]} -eq 0 ]; then
    echo "No processes found for '$process_to_extract'. Exiting."
    exit 1
fi

echo "Found ${#processes[@]} processes. Dumping memory..."

# Dump memory for each PID
for PID in "${processes[@]}"; do
    echo "Dumping memory for PID: $PID"
    if ! python vol.py -f "$memory_dump" windows.memmap.Memmap --dump --pid "$PID" &>/dev/null; then
        echo "Warning: Failed to dump memory for PID $PID."
    fi
done

# Gather .dmp files
dmp_files=(*.dmp)
if [ ${#dmp_files[@]} -eq 0 ]; then
    echo "No .dmp files found. Exiting."
    exit 1
fi

echo "Found ${#dmp_files[@]} memory dump files. Extracting files of type: $file_type_to_extract"

# Create output directory for extraction
mkdir -p "$extracted_dir"

# Run foremost on the .dmp files
if ! ./foremost.exe -t "$file_type_to_extract" -o "$extracted_dir" "${dmp_files[@]}" &>/dev/null; then
    echo "Error: Foremost extraction failed."
    exit 1
fi

echo "Extraction completed. Files saved to '$extracted_dir'."
exit 0
