#!/bin/bash

get_top_level_directory() {
    local path="$1"

    while [[ "$path" != "/" && "$path" != "." ]]; do
        top_level_dir="$path"
        path=$(dirname "$path")
    done

    echo "$top_level_dir"
}

display_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --filelist <file>   Specify a file containing the list of changed files"
    echo "  --pr_number <number> Specify the pull request number to retrieve changed files"
    echo "  --help              Display this help message"
    echo ""
    echo "Example usage:"
    echo "  $0 --filelist changed_files.txt"
    echo "  $0 --pr_number 1234"
    echo ""
    exit 0
}

filelist_path=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --filelist)
            filelist_path="$2"
            shift 2
            ;;
        --pr_number)
            pr_number="$2"
            shift 2
            ;;
        --help)
            display_help
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Check if the --filelist parameter is provided and valid
if [[ -n "$filelist_path" ]]; then
    # Read the changed files from the specified file
    if [[ -f "$filelist_path" ]]; then
        changed_files=$(cat "$filelist_path")
    else
        echo "File not found: $filelist_path"
        exit 1
    fi
else
    # Run the GitHub CLI command to get the changed files for the pull request
    changed_files=$(gh pr diff --name-only "$pr_number")
fi

while [[ -z "$top_level_dir" && -n "$changed_files" ]]; do
    top_level_dir=$(get_top_level_directory "$(dirname "$(echo "$changed_files" | head -n1)")")
    changed_files=$(echo "$changed_files" | tail -n +2)
done

if [[ -z "$top_level_dir" ]]; then
    echo "No changed files found"
    exit 0
fi

echo "Top-level directory: $top_level_dir"

while IFS= read -r path; do
    echo "Checking path: $path"
    echo "Path: $path"
    echo "Directory of path: $(dirname "$path")"

    current_dir=$(get_top_level_directory "$(dirname "$path")")
    echo "Current directory: $current_dir"

    if [[ "$current_dir" != "$top_level_dir" && "$current_dir" != "." && "$current_dir" != "" ]]; then
        echo "Error: Paths are not in the same top-level directory"
        echo "current_dir: $current_dir"
        exit 1
    fi
done <<< "$changed_files"

echo "All paths are in the same top-level directory or root of the repository"
exit 0
