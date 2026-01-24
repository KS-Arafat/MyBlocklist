#!/usr/bin/env bash
set -euo pipefail

INPUT="FTL_URL.txt"
OUTPUT="CustomBlocklist.txt"
TMP="$(mktemp)"

# Ensure output exists
touch "$OUTPUT"

# Normalize input:
# - trim whitespace
# - remove empty lines
sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$INPUT" | \
grep -v '^$' >> "$OUTPUT"

# Sort and deduplicate
sort -u "$OUTPUT" > "$TMP"
mv "$TMP" "$OUTPUT"
