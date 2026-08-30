# demo/

`demo.webp` is the animated demo embedded at the top of the root README.

## Regenerating it

1. Open a real Ghostty window (not another terminal emulator, not VHS/asciinema — see [`scripts/convert-demo.sh`](scripts/convert-demo.sh) for why).
2. Start a screen recording (⌘⇧5 or QuickTime → New Screen Recording), selecting the Ghostty window.
3. In that window, run through:
   - `ls -hal`
   - `git status`
   - `./ghostty-themes-bar`
   - arrow through a handful of themes
   - type two theme names to fuzzy-search for them by name, `Enter` on the last one
4. Stop the recording, then convert it:
   ```bash
   demo/scripts/convert-demo.sh --trim 5 path/to/raw-recording.mov demo/demo.webp
   ```
   (`--trim 5` drops the first 5s — adjust or omit as needed. See the script's
   `--fps`/`--width`/`--quality` flags for tuning; 8fps/900px/q75 won out over
   15fps and over encoding WebP directly from raw frames in testing — see the
   comments at the top of the script.)
