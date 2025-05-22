#!/bin/bash
set -e

# Destination path
DEST_DIR="/default/images"

# Temporary directory for cloning
TMP_DIR="/tmp/crestron_repo"

# Install required package (if not available)
if ! command -v git &> /dev/null; then
    echo "git not found. Installing..."
    apt-get update && apt-get install -y git
fi

# Clone repository
git clone https://github.com/Michdo93/openHAB-Crestron-RoomView-Control.git "$TMP_DIR"

# Create target directory and move images
mkdir -p "$(dirname "$DEST_DIR")"
mv "$TMP_DIR/images/"* "$DEST_DIR"

# Deleting cloned data
rm -rf "$TMP_DIR"

echo "Images directory was successfully moved to $DEST_DIR and the rest was deleted."
