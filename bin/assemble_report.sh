#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Error: Invalid usage."
  echo "Usage: $0 <directory>"
  exit 1
fi

target="$1"

output="$target/failed_login_summary.html"

temp=$(mktemp)

for file in "$target/country_dist.html" "$target/hours_dist.html" "$target/username_dist.html"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: $file not found."
    rm "$temp"
    exit 1
  fi
done

{
  cat "$target/country_dist.html"
  cat "$target/hours_dist.html"
  cat "$target/username_dist.html"
} > "$temp"

if [[ -x "./bin/wrap_contents.sh" ]]; then
  ./bin/wrap_contents.sh "$temp" "html_components/summary_plots" "$output"
else
  echo "Error: wrap_contents.sh not found or not executable."
  rm "$temp"
  exit 1
fi

rm "$temp"

echo "Report created at: $output"

echo "==== Report Contents: ===="
cat "$output"
