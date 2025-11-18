#!/bin/bash
# rename-folder.sh
# Created: 2024-05-24, dalthonmh
# Description:
# This script renames folders by replacing dots in the folder name with dashes.
# For example, it renames folders from the format YYYY.MM.DD to YYYY-MM-DD.

# Requirements:
# - The script must be executed in the directory containing the folders to rename.

# Notes:
# - Only folders matching the format YYYY.MM.DD will be renamed.
# - Ensure you have write permissions in the directory.

# Usage:
#   ./rename-folder.sh

# Download this script:
#   wget https://github.com/dalthonmh/scripts/blob/main/rename-folder.sh -O rename-folder.sh


# Years to consider
years=("2022" "2023" "2024")

# Iterate over each defined year
for year in "${years[@]}"; do
    # Find all folders with the format YYYY.MM.DD
    for dir in ${year}.??.??; do
        if [[ -d "$dir" ]]; then
            # Extract year, month, and day
            y=$(echo $dir | cut -d'.' -f1)
            m=$(echo $dir | cut -d'.' -f2)
            d=$(echo $dir | cut -d'.' -f3)

            # Create the new name with the format YYYY-MM-DD
            new_name="${y}-${m}-${d}"

            # Rename the folder
            mv "$dir" "$new_name"

            # Confirm the renaming
            echo "Renamed: $dir -> $new_name"
        fi
    done
done