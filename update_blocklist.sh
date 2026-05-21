#!/usr/bin/env bash
set -euo pipefail

INPUT="FTL_URL.txt"
IGNORE="Ignore.txt"
OUTPUT1="CustomBlocklist1.txt"
OUTPUT2="CustomBlocklist2.txt"
TMP="$(mktemp)"
TMP2="$(mktemp)"

touch "$OUTPUT1"
touch "$OUTPUT2"

# Normalize input: trim whitespace + remove empty lines
sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$INPUT" | grep -v '^$' > "$TMP"

# Filter out domains listed in Ignore.txt if it exists and is non-empty
if [[ -f "$IGNORE" && -s "$IGNORE" ]]; then
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$IGNORE" | grep -v '^$' > "$TMP2"
    grep -Fxvf "$TMP2" "$TMP" > "$OUTPUT1" || true
else
    cp "$TMP" "$OUTPUT1"
fi

# Sort & deduplicate by subdomain into OUTPUT2
sort -u "$OUTPUT1" > "$OUTPUT2"

# Sort & deduplicate by SDL (domain) into TMP
awk -F. '{
    n=NF
    if(n>=2){
        sdl=$(n-1)"."$n
        print sdl,$0
    } else {
        print $0,$0
    }
}' "$OUTPUT1" | sort -k1,1 | awk '{print $2}' > "$TMP"

# Replace OUTPUT1 with SDL-sorted version
mv "$TMP" "$OUTPUT1"

rm -f "$TMP" "$TMP2"