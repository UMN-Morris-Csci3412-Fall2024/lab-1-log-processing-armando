#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Error: Invalid usage."
  echo "Usage: $0 <directory>"
  exit 1
fi

target_dir="$1"

output_file="$target_dir/failed_login_summary.html"

temp_file=$(mktemp)

for file in "$target_dir/country_dist.html" "$target_dir/hours_dist.html" "$target_dir/username_dist.html"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: $file not found."
    rm "$temp_file"
    exit 1
  fi
done

{
  cat "$target_dir/country_dist.html"
  cat "$target_dir/hours_dist.html"
  cat "$target_dir/username_dist.html"
} > "$temp_file"

if [[ -x "./bin/wrap_contents.sh" ]]; then
  ./bin/wrap_contents.sh "$temp_file" "html_components/summary_plots" "$output_file"
else
  echo "Error: wrap_contents.sh not found or not executable."
  rm "$temp_file"
  exit 1
fi

rm "$temp_file"

echo "Report created at: $output_file"

echo "==== Report Contents: ===="
cat "$output_file"
