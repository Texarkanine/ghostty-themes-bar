# demo/

TODO(tex): drop `demo.gif` here once recorded.

1. Open a real Ghostty window (not another terminal emulator, not VHS/asciinema — see [`scripts/convert-demo.sh`](../scripts/convert-demo.sh) for why).
2. Start a screen recording (⌘⇧5 or QuickTime → New Screen Recording), selecting the Ghostty window.
3. In that window, run through:
   - `ls -hal`
   - `git status`
   - `./ghostty-themes-bar`
   - arrow through a handful of themes
   - type two theme names to fuzzy-search for them by name, `Enter` on the last one
4. Stop the recording, then convert it:
   ```bash
   scripts/convert-demo.sh path/to/raw-recording.mov demo/demo.gif
   ```
5. Swap the placeholder image reference in the root `README.md` if needed (it already points at `demo/demo.gif`).
