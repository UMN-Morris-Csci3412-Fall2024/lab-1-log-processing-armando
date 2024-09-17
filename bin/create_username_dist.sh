#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

target_dir="$1"
if ! cd "$target_dir"; then
  echo "Error: Unable to access directory $target_dir"
  exit 1
fi

output_file="username_dist.html"
header_file="../html_components/username_dist_header.html"
footer_file="../html_components/username_dist_footer.html"

if [ -f "$header_file" ]; then
  cat "$header_file" > "$output_file"
else
  echo "Header file missing: $header_file"
  exit 1
fi

temp_usernames=$(mktemp)

find . -mindepth 1 -maxdepth 1 -type d | while read -r sub_dir; do
  login_file="$sub_dir/failed_login_data.txt"
  if [ -f "$login_file" ]; then
    awk '{print $4}' "$login_file" >> "$temp_usernames"
  fi
done

if [ -s "$temp_usernames" ]; then
  sort "$temp_usernames" | uniq -c | while read -r count username; do
    printf "data.addRow([\x27%s\x27, %d]);\n" "$username" "$count" >> "$output_file"
  done
else
  echo "No usernames found."
  exit 1
fi

if [ -f "$footer_file" ]; then
  cat "$footer_file" >> "$output_file"
else
  echo "Footer file missing: $footer_file"
  exit 1
fi
rm -f "$temp_usernames"

echo "Username distribution chart created: $output_file"
