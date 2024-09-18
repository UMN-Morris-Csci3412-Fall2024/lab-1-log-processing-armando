#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

target="$1"
if ! cd "$target"; then
  echo "Error: Could not access directory $target"
  exit 1
fi

output="hours_dist.html"
header="../html_components/hours_dist_header.html"
footer="../html_components/hours_dist_footer.html"

if [ ! -f "$header" ] || [ ! -f "$footer" ]; then
  echo "error, missing required header or footer files."
  exit 1
fi

cat "$header" > "$output"

temp=$(mktemp)

for sub_dir in $(ls -d */); do
    login_file="${sub_dir}failed_login_data.txt"
    if [ -f "$login_file" ]; then
        while read -r line; do
            echo "$line" | awk '{print $3}' >> "$temp"
        done < "$login_file"
    fi
done


if [ -s "$temp" ]; then
    sort "$temp" | uniq -c | awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' >> "$output"
else
    echo "error no login data found."
    rm -f "$temp"
    exit 1
fi
cat "$footer" >> "$output"

rm -f "$temp"

echo "hours distribution chart created at $output"
