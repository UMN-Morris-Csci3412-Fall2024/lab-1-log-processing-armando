#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

target_dir="$1"
if ! cd "$target_dir"; then
  echo "Error: Could not access directory $target_dir"
  exit 1
fi

output_file="hours_dist.html"
header_file="../html_components/hours_dist_header.html"
footer_file="../html_components/hours_dist_footer.html"

if [ ! -f "$header_file" ] || [ ! -f "$footer_file" ]; then
  echo "Error: Missing required header or footer files."
  exit 1
fi

cat "$header_file" > "$output_file"

temp_file=$(mktemp)

for sub_dir in */; do
    login_data="${sub_dir}failed_login_data.txt"
    if [ -f "$login_data" ]; then
        awk '{print $3}' "$login_data" >> "$temp_file"
    fi
done

if [ -s "$temp_file" ]; then
    sort "$temp_file" | uniq -c | awk '{
        printf "data.addRow([\x27%s\x27, %d]);\n", $2, $1
    }' >> "$output_file"
else
    echo "Error: No login data found."
    rm -f "$temp_file"
    exit 1
fi
cat "$footer_file" >> "$output_file"

rm -f "$temp_file"

echo "Hours distribution chart created at $output_file"
