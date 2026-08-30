#!/usr/bin/env bash
# Converts a raw screen recording (.mov/.mp4) into a README-sized GIF.
#
# Why not asciinema/VHS: both record the byte stream sent to a pty. Ghostty's
# live theme reload repaints already-rendered content by swapping its color
# palette at the terminal-emulator level — no new bytes hit the pty when that
# happens, so pty-recording tools show a picker but never show the recolor
# effect. A real screen capture is the only way to show it.
#
# Usage:
#   scripts/convert-demo.sh path/to/raw-recording.mov [demo/demo.gif]
#
# Requires: ffmpeg (brew install ffmpeg)

set -euo pipefail

src="${1:?usage: convert-demo.sh <input.mov> [output.gif]}"
dest="${2:-demo/demo.gif}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "convert-demo.sh: need ffmpeg (brew install ffmpeg)" >&2
  exit 1
fi

mkdir -p "$(dirname "$dest")"

palette="$(mktemp -t ghostty-demo-palette).png"
trap 'rm -f "$palette"' EXIT

# Two-pass palette-based GIF encode: much smaller/cleaner than a naive
# single-pass conversion, still simple enough for a README asset.
ffmpeg -y -i "$src" -vf "fps=15,scale=900:-1:flags=lanczos,palettegen" "$palette"
ffmpeg -y -i "$src" -i "$palette" \
  -filter_complex "fps=15,scale=900:-1:flags=lanczos[x];[x][1:v]paletteuse" \
  "$dest"

echo "wrote $dest"
