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
output_file="failed_login_data.txt"

grep -h 'Failed password' $(find . -type f) | awk '
  # Handle "invalid user" log entries
  /invalid user/ {
    date = $1 " " $2; time = substr($3, 1, 2); user = $11; ip = $13;
    print date, time, user, ip;
  }
  # Handle valid user log entries
  !/invalid user/ {
    date = $1 " " $2; time = substr($3, 1, 2); user = $9; ip = $11;
    print date, time, user, ip;
  }
' > "$output_file"

if [ -f "$output_file" ]; then
  echo "Failed login data successfully written to $output_file"
else
  echo "Error: Failed to write login data"
fi
