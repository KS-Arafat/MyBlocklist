#!/usr/bin/env bash
set -euo pipefail

INPUT="FTL_URL.txt"
DB_FILE="~/pihole-unbound/pihole/etc-pihole/pihole-FTL.db" # Adjust this path if your FTL database is located elsewhere

# Ask for Pi-hole SSH details
read -rp "Enter Pi-hole SSH address: " PIHOLE_HOST
read -rp "Enter Pi-hole SSH user: " PIHOLE_USER

# Validate inputs are not empty
if [[ -z "$PIHOLE_HOST" || -z "$PIHOLE_USER" ]]; then
    echo "Error: SSH address and user cannot be empty." >&2
    exit 1
fi

# Fetch only blocked/denied domains from Pi-hole via SSH
echo "Fetching denied domains from ${PIHOLE_USER}@${PIHOLE_HOST}..."
ssh "${PIHOLE_USER}@${PIHOLE_HOST}" \
    "sqlite3 ${DB_FILE} \
    'SELECT DISTINCT domain FROM queries WHERE status IN (1,4,6,14,15,16) ORDER BY domain;'" \
    > "$INPUT"

echo "Fetched $(wc -l < "$INPUT") denied domains into $INPUT."
