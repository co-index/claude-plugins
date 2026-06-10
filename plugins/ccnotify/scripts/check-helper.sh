#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: if neither the ccnotify helper nor terminal-notifier is
# available, leave a one-line hint so the user learns how to get clickable
# notifications. Notifications still work without the helper via osascript.

[[ "$(uname)" == "Darwin" ]] || exit 0

is_ccnotify_shim() {
  # Unrelated tools are also named "ccnotify"; ours is a shim that
  # references the ccnotify.app bundle.
  [[ -x "$1" ]] && head -c 4096 "$1" 2>/dev/null | grep -q "ccnotify.app"
}

for candidate in /opt/homebrew/bin/ccnotify /usr/local/bin/ccnotify "$(command -v ccnotify 2>/dev/null || true)"; do
  [[ -n "$candidate" ]] && is_ccnotify_shim "$candidate" && exit 0
done

command -v terminal-notifier >/dev/null 2>&1 && exit 0
[[ -x /opt/homebrew/bin/terminal-notifier || -x /usr/local/bin/terminal-notifier ]] && exit 0

echo "ccnotify plugin: notifications currently use the non-clickable osascript fallback. For clickable banners that jump back to this app, install the helper once: brew install co-index/tap/ccnotify (details: https://github.com/co-index/ccnotify). Please relay this hint to the user."
