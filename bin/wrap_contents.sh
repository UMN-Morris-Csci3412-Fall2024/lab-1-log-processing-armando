#!/bin/bash
if [ "$#" -ne 3 ]; then
  echo "$0 content_file specifier output_file"
  exit 1
fi

content_file=$1
specifier=$2
output_file=$3

header_file="${specifier}_header.html"
footer_file="${specifier}_footer.html"

if [ ! -f "$header_file" ] || [ ! -f "$content_file" ] || [ ! -f "$footer_file" ]; then
  echo "Few files don't exist"
  exit 1
fi

cat "$header_file" "$content_file" "$footer_file" > "$output_file"

echo "Output written to $output_file"
