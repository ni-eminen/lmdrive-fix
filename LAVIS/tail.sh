#!/usr/bin/env bash

# Find the most recently modified .out file in the current directory
latest_out=$(ls -t *.out 2>/dev/null | head -n 1)

if [[ -z "$latest_out" ]]; then
  echo "No .out files found in the current directory."
  exit 1
fi

echo "Tailing: $latest_out"
tail -f "$latest_out"

