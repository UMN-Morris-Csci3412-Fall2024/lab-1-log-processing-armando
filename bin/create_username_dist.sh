#!/bin/bash

# Use modern command substitution syntax
here=$(pwd)

# Check if a target directory is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

target="$1"

# Check if the target directory is accessible
if ! cd "$target"; then
  echo "Error: Unable to access directory $target"
  exit 1
fi

# Define output file and header/footer paths
out="username_dist.html"
head="$here/html_components/username_dist_header.html"
foot="$here/html_components/username_dist_footer.html"

# Check if the header file exists, and write it to the output
if [ -f "$head" ]; then
  cat "$head" > "$out"
else
  echo "Header file missing (we are here: $here): $head"
  exit 1
fi

# Create a temporary file to store username data
temp=$(mktemp)

# Find subdirectories and process the failed login data
find . -mindepth 1 -maxdepth 1 -type d | while read -r sub_dir; do
  login="$sub_dir/failed_login_data.txt"
  if [ -f "$login" ]; then
    awk '{print $4}' "$login" >> "$temp"
  fi
done

# Process the temporary file if it contains usernames
if [ -s "$temp" ]; then
  sort "$temp" | uniq -c | while read -r count username; do
    printf "data.addRow([\x27%s\x27, %d]);\n" "$username" "$count" >> "$out"
  done
else
  echo "No usernames found."
  exit 1
fi

# Check if the footer file exists, and append it to the output
if [ -f "$foot" ]; then
  cat "$foot" >> "$out"
else
  echo "Footer file missing: $foot"
  exit 1
fi

# Clean up the temporary file
rm -f "$temp"

# Success message
echo "Username distribution chart created: $out"
