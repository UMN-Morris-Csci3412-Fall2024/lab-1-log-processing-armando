#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

cd "$1" || exit

temp_file=$(mktemp)

find . -type f -name "failed_login_data.txt" -exec cat {} + | \
awk '{print $4}' | sort | uniq -c | \
awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > "$temp_file"

./bin/wrap_contents.sh "$temp_file" "username_dist" "$1/username_dist.html"
rm "$temp_file"

echo "Username distribution written to $1/username_dist.html"
