#!/usr/bin/env bash
set -euo pipefail

INPUT="FTL_URL.txt"
OUTPUT="CustomBlocklist.txt"
OUTPUTN="CustomBlocklist2.txt"
TMP="$(mktemp)"

# Ensure output exists
touch "$OUTPUT"

# Normalize input:
# - trim whitespace
# - remove empty lines
sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$INPUT" | \
grep -v '^$' >> "$OUTPUT"

# Sort and deduplicate by subdomain
sort -u "$OUTPUT" > "$OUTPUTN"

# Sort and deduplicate by domain
awk -F. '{
    n=NF
    # capture the last 2 fields as SDL
    if(n>=2){
        sdl=$(n-1)"."$n
        print sdl,$0
    } else {
        print $0,$0
    }
}' "$OUTPUT" | sort -k1,1 -u | awk '{print $2}' > "$TMP"
mv "$TMP" "$OUTPUT"
rm -f "$TMP"
