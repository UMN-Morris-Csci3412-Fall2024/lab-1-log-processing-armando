#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

directory="$1"
if ! cd "$directory"; then
  echo "Error: Unable to access directory $directory"
  exit 1
fi
temp_file=$(mktemp)

awk '{print $3}' $(find . -type f -name "failed_login_data.txt") | sort | uniq -c | \
awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > "$temp_file"

./bin/wrap_contents.sh "$temp_file" "username_dist" "$directory/username_dist.html"

rm -f "$temp_file"

echo "Username distribution report created at $directory/username_dist.html"
