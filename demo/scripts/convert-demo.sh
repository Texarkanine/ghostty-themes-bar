#!/usr/bin/env bash
# Converts a raw screen recording (.mov/.mp4) into a README-sized WebP.
#
# Why not asciinema/VHS: both record the byte stream sent to a pty. Ghostty's
# live theme reload repaints already-rendered content by swapping its color
# palette at the terminal-emulator level — no new bytes hit the pty when that
# happens, so pty-recording tools show a picker but never show the recolor
# effect. A real screen capture is the only way to show it.
#
# Why GIF-then-WebP instead of WebP straight from the source frames: encoding
# WebP directly from raw PNG frames came out *larger* in testing (5.3M vs
# 2.5M) — per-frame font anti-aliasing adds high-frequency noise that hurts
# lossy compression. Routing through a palette-quantized GIF first flattens
# that noise, and gif2webp on the result wins comfortably.
#
# Usage:
#   demo/scripts/convert-demo.sh path/to/raw-recording.mov [demo/demo.webp]
#   demo/scripts/convert-demo.sh --trim 5 --fps 8 path/to/raw-recording.mov
#
# Requires: ffmpeg (brew install ffmpeg), gif2webp (brew install webp)

set -euo pipefail

trim=0
fps=8
width=900
quality=75

while [[ $# -gt 0 ]]; do
  case "$1" in
    --trim) trim="$2"; shift 2 ;;
    --fps) fps="$2"; shift 2 ;;
    --width) width="$2"; shift 2 ;;
    --quality) quality="$2"; shift 2 ;;
    --) shift; break ;;
    -*) echo "convert-demo.sh: unknown flag $1" >&2; exit 1 ;;
    *) break ;;
  esac
done

src="${1:?usage: convert-demo.sh [--trim SECS] [--fps N] [--width PX] [--quality Q] <input.mov> [output.webp]}"
dest="${2:-demo/demo.webp}"

for cmd in ffmpeg gif2webp; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "convert-demo.sh: need $cmd (brew install ffmpeg webp)" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$dest")"

work="$(mktemp -d -t ghostty-demo-convert)"
trap 'rm -rf "$work"' EXIT

trimmed="$src"
if [[ "$trim" != "0" ]]; then
  trimmed="$work/trimmed.mov"
  ffmpeg -y -i "$src" -ss "$trim" -c:v libx264 -crf 18 -preset veryfast -c:a copy "$trimmed"
fi

# Two-pass palette-based GIF encode as an intermediate step (see comment above).
ffmpeg -y -i "$trimmed" -vf "fps=$fps,scale=$width:-1:flags=lanczos,palettegen" "$work/palette.png"
ffmpeg -y -i "$trimmed" -i "$work/palette.png" \
  -filter_complex "fps=$fps,scale=$width:-1:flags=lanczos[x];[x][1:v]paletteuse" \
  "$work/demo.gif"

gif2webp -q "$quality" "$work/demo.gif" -o "$dest"

echo "wrote $dest"
