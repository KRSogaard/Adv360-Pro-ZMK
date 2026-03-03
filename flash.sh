#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIRMWARE_DIR="$SCRIPT_DIR/firmware"
VOLUME="/Volumes/ADV360PRO"

# --- Build firmware ---
echo "Building firmware..."
make -C "$SCRIPT_DIR" all
echo ""
echo "Build complete."
echo ""

# Find the newest left and right firmware files
left_fw=$(ls -t "$FIRMWARE_DIR"/*-left-clique.uf2 2>/dev/null | head -1)
right_fw=$(ls -t "$FIRMWARE_DIR"/*-right-clique.uf2 2>/dev/null | head -1)

if [ -z "$left_fw" ]; then
  echo "Error: No left firmware found in $FIRMWARE_DIR"
  exit 1
fi

if [ -z "$right_fw" ]; then
  echo "Error: No right firmware found in $FIRMWARE_DIR"
  exit 1
fi

echo "Firmware to flash:"
echo "  Left:  $(basename "$left_fw")"
echo "  Right: $(basename "$right_fw")"
echo ""

# --- Left keyboard ---
echo "Put the LEFT keyboard into mount mode: Mod + Macro 1"
echo "Wait until all 3 LEDs are blinking green."
read -rp "Press Enter when ready..."

if [ ! -d "$VOLUME" ]; then
  echo "Error: $VOLUME not found. Is the left keyboard mounted?"
  exit 1
fi

echo "Copying left firmware..."
cp "$left_fw" "$VOLUME/"
echo "Left firmware copied. The keyboard will reboot automatically."
echo ""

# Wait for the volume to unmount before continuing
echo "Waiting for left keyboard to reboot..."
while [ -d "$VOLUME" ]; do
  sleep 1
done
echo "Left keyboard rebooted."
echo ""

# --- Right keyboard ---
echo "Put the RIGHT keyboard into mount mode: Mod + Macro 3"
echo "Wait until all 3 LEDs are blinking green."
read -rp "Press Enter when ready..."

if [ ! -d "$VOLUME" ]; then
  echo "Error: $VOLUME not found. Is the right keyboard mounted?"
  exit 1
fi

echo "Copying right firmware..."
cp "$right_fw" "$VOLUME/"
echo "Right firmware copied. The keyboard will reboot automatically."
echo ""

echo "Waiting for right keyboard to reboot..."
while [ -d "$VOLUME" ]; do
  sleep 1
done

echo "Done! Both halves have been flashed."
