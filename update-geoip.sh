#!/bin/bash
set -e

LICENSE_KEY="${LICENSE_KEY:-}"
DB_DIR="/data"
DB_FILE="GeoLite2-City.mmdb"

if [ -z "$LICENSE_KEY" ]; then
    echo "[$(date)] ERROR: LICENSE_KEY not set"
    exit 1
fi

TMP_DIR=$(mktemp -d)
ZIP_FILE="$TMP_DIR/GeoLite2-City.tar.gz"

echo "[$(date)] Downloading GeoLite2 City DB..."
curl -s -L "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${LICENSE_KEY}&suffix=tar.gz"   -o "$ZIP_FILE"

tar -xzf "$ZIP_FILE" -C "$TMP_DIR"
NEW_DB=$(find "$TMP_DIR" -name "*.mmdb" | head -n 1)

if [ -f "$NEW_DB" ]; then
    mv "$NEW_DB" "$DB_DIR/$DB_FILE"
    echo "[$(date)] Updated GeoLite2-City DB"
else
    echo "[$(date)] ERROR: No MMDB file found!"
    exit 1
fi

rm -rf "$TMP_DIR"

openresty -s reload || true
