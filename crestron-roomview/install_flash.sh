#!/bin/bash
set -e

FLASH_VERSION="32.0.0.371"
FLASH_URL="https://archive.org/download/flash_player_32.0.0.371/flash_player_npapi_linux.x86_64.tar.gz"

echo "Downloading Flash Player version $FLASH_VERSION..."
wget -q --show-progress -O /tmp/flash.tar.gz "$FLASH_URL"

echo "Extracting Flash Player..."
tar -xzf /tmp/flash.tar.gz -C /tmp

echo "Installing libflashplayer.so to /usr/lib/mozilla/plugins/"
mkdir -p /opt/firefox/plugins/
cp /tmp/libflashplayer.so /opt/firefox/plugins/

echo "Cleaning up..."
rm /tmp/flash.tar.gz /tmp/libflashplayer.so

echo "Flash Player $FLASH_VERSION installed successfully."
