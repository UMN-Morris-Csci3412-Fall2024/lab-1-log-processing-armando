#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <log_archive1.tgz> [<log_archive2.tgz> ...]"
  exit 1
fi
scratch_dir=$(mktemp -d)
echo "Created scratch directory: $scratch_dir"

for archive in "$@"; do
  echo "Processing archive: $archive"
  tar -xzvf "$archive" -C "$scratch_dir"
done

for machine_dir in "$scratch_dir"/*; do
  echo "Running process_client_logs.sh for $machine_dir"
  ./bin/process_client_logs.sh "$machine_dir"
done

echo "Generating username distribution report"
./bin/create_username_dist.sh "$scratch_dir"

echo "Generating hours distribution report"
./bin/create_hours_dist.sh "$scratch_dir"

echo "Generating country distribution report"
./bin/create_country_dist.sh "$scratch_dir"

echo "Assembling the final report"
./bin/assemble_report.sh "$scratch_dir"

mv "$scratch_dir/failed_login_summary.html" .
echo "Final report saved as failed_login_summary.html"

rm -rf "$scratch_dir"
echo "Cleaned up the scratch directory"
