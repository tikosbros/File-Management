#!/bin/bash

# Set recursive mode to false by default
RECURSIVE=false

# Show usage help
usage() {
    echo "Usage: $0 [-r] directory"
    echo "  -r   Enable recursive mode"
    exit 1
}

# Parse options (only -r for recursion)
while getopts ":r" opt; do
    case $opt in
        r) RECURSIVE=true ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

# Check if directory was provided
if [ -z "$1" ]; then
    usage
fi

DIR="$1"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a valid directory."
    exit 1
fi

# Set find command based on recursive flag
if [ "$RECURSIVE" = true ]; then
    FIND_CMD="find \"$DIR\" -type f"
else
    FIND_CMD="find \"$DIR\" -maxdepth 1 -type f"
fi

# Use eval to execute the find command safely
eval "$FIND_CMD" | while read -r file; do
    # Extract the filename and extension
    filename=$(basename "$file")
    extension="${filename##*.}"

    # Skip files without an extension
    if [ "$filename" = "$extension" ]; then
        echo "Skipping '$filename' (no extension)"
        continue
    fi

    # Create destination folder (if needed)
    dest="$DIR/$extension"
    mkdir -p "$dest"

    # Move file into the folder
    if mv -n "$file" "$dest/"; then
        echo "Moved '$filename' to '$extension/'"
    else
        echo "Failed to move '$filename'"
    fi
done

