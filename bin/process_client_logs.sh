#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

directory="$1"
if ! cd "$directory"; then
  echo "Error: Failed to change directory to $directory"
  exit 1
fi

output="failed_login_data.txt"
grep -h 'Failed password' $(find . -type f) | awk '
  /invalid user/ {
    print $1, $2, substr($3, 1, 2), $11, $13;
  }
  !/invalid user/ {
    print $1, $2, substr($3, 1, 2), $9, $11;
  }
' > "$output"

if [ -f "$output" ]; then
  echo "Failed login data written to $output"
else
  echo "Error: Failed to write login data"
  exit 1
fi
