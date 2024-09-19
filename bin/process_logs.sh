#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <log_archive1.tgz> <log_archive2.tgz> ..."
  exit 1
fi

SCRATCH_DIR=$(mktemp -dp .)

trap 'rm -rf "$SCRATCH_DIR"' EXIT

for ARCHIVE in "$@"; do
  CLIENT_NAME=$(basename "$ARCHIVE" _secure.tgz)

  CLIENT_DIR="$SCRATCH_DIR/$CLIENT_NAME"
  mkdir -p "$CLIENT_DIR"

  if tar -xzf "$ARCHIVE" -C "$CLIENT_DIR"; then
    echo "Extracted $ARCHIVE successfully."
  else
    echo "Error extracting $ARCHIVE."
    exit 1
  fi

  if bin/process_client_logs.sh "$CLIENT_DIR"; then
    echo "Processed logs for $CLIENT_NAME."
  else
    echo "Error processing logs for $CLIENT_NAME."
    exit 1
  fi
done

if bin/create_username_dist.sh "$SCRATCH_DIR"; then
  echo "Generated username distribution."
else
  echo "Error generating username distribution."
  exit 1
fi

if bin/create_hours_dist.sh "$SCRATCH_DIR"; then
  echo "Generated hours distribution."
else
  echo "Error generating hours distribution."
  exit 1
fi


if bin/create_country_dist.sh "$SCRATCH_DIR"; then
  echo "Generated country distribution."
else
  echo "Error generating country distribution."
  exit 1
fi

if bin/assemble_report.sh "$SCRATCH_DIR"; then
  echo "Report assembled successfully."
else
  echo "Error assembling report."
  exit 1
fi

if mv "$SCRATCH_DIR/failed_login_summary.html" .; then
  echo "Report generated successfully: failed_login_summary.html"
else
  echo "Error moving the report file."
  exit 1
fi

exit 0