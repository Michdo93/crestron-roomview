#!/usr/bin/env bash
set -e

URL_FILE="/config/url.txt"
RESOLUTION_FILE="/config/resolution.txt"
DISPLAY_FILE="/config/display.txt"

# Default values
URL="about:blank"
RESOLUTION="1920x1200x24"
DISPLAY=":99"

[ -f /root/.Xauthority ] || touch /root/.Xauthority

if [ ! -f /app/crestron_roomview.py ]; then
  echo "/app is empty, copy default files over..."
  cp -r /default/* /app/
fi

# Load URL
if [ -f "$URL_FILE" ]; then
  URL=$(cat "$URL_FILE")
fi

# Load Resolution
if [ -f "$RESOLUTION_FILE" ]; then
  RESOLUTION=$(cat "$RESOLUTION_FILE")
fi

# Load Display from file, strip whitespace and validate
if [ -f "$DISPLAY_FILE" ]; then
  DISPLAY=$(tr -d '[:space:]' < "$DISPLAY_FILE")
  echo "[INFO] Loaded DISPLAY from file: '$DISPLAY'"
fi

# Validate DISPLAY format
if ! [[ "$DISPLAY" =~ ^:[0-9]+$ ]]; then
  echo "[ERROR] Invalid DISPLAY value: '$DISPLAY'. Falling back to ':99'"
  DISPLAY=":99"
fi

export DISPLAY

# Cleanup: remove old X lock if it exists (avoid "server is already active")
LOCK_FILE="/tmp/.X${DISPLAY#:}-lock"
if [ -f "$LOCK_FILE" ]; then
    echo "[INFO] Removing leftover lock file: $LOCK_FILE"
    rm -f "$LOCK_FILE"
fi

echo "[INFO] Starting Xvfb at DISPLAY $DISPLAY with Resolution $RESOLUTION..."
Xvfb "$DISPLAY" -screen 0 "$RESOLUTION" &
XVFB_PID=$!

echo "[INFO] Waiting for DISPLAY $DISPLAY..."
for i in {1..10}; do
    if xdpyinfo -display "$DISPLAY" > /dev/null 2>&1; then
        echo "[INFO] DISPLAY $DISPLAY is available."
        break
    else
        echo "[WARN] DISPLAY $DISPLAY is not available yet, waiting..."
        sleep 1
    fi
done

openbox &
sleep 1

echo "[INFO] Starting x11vnc..."
x11vnc -display "$DISPLAY" -nopw -forever -shared -logfile /tmp/x11vnc.log &
VNC_PID=$!

sleep 1

echo "[INFO] Starting Firefox with URL: $URL"
firefox "$URL" &
FF_PID=$!

sleep 5
xdotool search --onlyvisible --class "Firefox" windowactivate --sync key F11

echo "[INFO] Processes are running. Keep the container alive."
wait $XVFB_PID $VNC_PID $FF_PID || true

tail -f /dev/null
