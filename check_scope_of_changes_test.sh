#!/bin/bash

get_top_level_directory() {
    local path="$1"

    while [[ "$path" != "/" && "$path" != "." ]]; do
        top_level_dir="$path"
        path=$(dirname "$path")
    done

    echo "$top_level_dir"
}

changed_files=$(cat changed_files.txt)
echo "RP: $(echo "$changed_files" | head -n1)"

top_level_dir=$(get_top_level_directory "$(dirname "$(echo "$changed_files" | head -n1)")")
echo "Top-level directory: $top_level_dir"

while IFS= read -r path; do
    echo "Checking path: $path"
    echo "Path: $path"
    echo "Directory of path: $(dirname "$path")"

    current_dir=$(get_top_level_directory "$(dirname "$path")")
    echo "Current directory: $current_dir"

    if [[ "$current_dir" != "$top_level_dir" && "$current_dir" != "." ]]; then
        echo "Error: Paths are not in the same top-level directory"
        echo "current_dir: $current_dir"
        exit 1
    fi
done <<< "$changed_files"

echo "All paths are in the same top-level directory or root of the repository"
exit 0