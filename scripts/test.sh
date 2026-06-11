#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plugin_dir="$repo_dir/plugins/ccnotify"
failures=0

check() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "ok: $name"
  else
    echo "FAIL: $name"
    failures=$((failures + 1))
  fi
}

echo "== Syntax and manifest checks =="
check "bash -n notify.sh" bash -n "$plugin_dir/scripts/notify.sh"
check "bash -n check-helper.sh" bash -n "$plugin_dir/scripts/check-helper.sh"
check "json: plugin.json" /usr/bin/python3 -m json.tool "$plugin_dir/.claude-plugin/plugin.json"
check "json: marketplace.json" /usr/bin/python3 -m json.tool "$repo_dir/.claude-plugin/marketplace.json"
check "json: hooks.json" /usr/bin/python3 -m json.tool "$plugin_dir/hooks/hooks.json"
check "scripts are executable" test -x "$plugin_dir/scripts/notify.sh" -a -x "$plugin_dir/scripts/check-helper.sh"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Behavioral checks need macOS; skipped."
  [[ "$failures" -eq 0 ]] && echo "All checks passed." && exit 0
  echo "$failures check(s) failed."
  exit 1
fi

echo "== notify.sh behavior (stub helper) =="
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

stub="$tmp/ccnotify"
cat > "$stub" <<'SH'
#!/bin/bash
# Test stub standing in for the ccnotify.app shim; records its arguments.
printf '%s\n' "$@" > "$CCNOTIFY_TEST_OUT"
SH
chmod +x "$stub"

run_notify() {
  local json="$1"
  local out="$2"
  local claude_dir="$3"
  printf '%s' "$json" \
    | env CCNOTIFY_BIN="$stub" CCNOTIFY_TEST_OUT="$out" \
        CLAUDE_CONFIG_DIR="$claude_dir" TERM_PROGRAM=Apple_Terminal \
        bash "$plugin_dir/scripts/notify.sh"
}

mkdir -p "$tmp/clean-claude"
run_notify '{"hook_event_name":"Stop","cwd":"/tmp/myproj","session_id":"abcdef123456"}' \
  "$tmp/stop-args" "$tmp/clean-claude"
check "Stop event reaches the helper" test -s "$tmp/stop-args"
check "Stop title carries the project" grep -qx "Claude · myproj" "$tmp/stop-args"
check "Stop body says task completed" grep -qx "Task completed" "$tmp/stop-args"
check "Stop uses the Glass sound" grep -qx "Glass" "$tmp/stop-args"
check "TERM_PROGRAM maps to Terminal bundle id" grep -qx "com.apple.Terminal" "$tmp/stop-args"
check "subtitle includes the session" grep -q "session abcdef12" "$tmp/stop-args"

run_notify '{"hook_event_name":"Notification","cwd":"/tmp/myproj","message":"Claude is waiting"}' \
  "$tmp/notification-args" "$tmp/clean-claude"
check "Notification body mentions attention" grep -q "Claude needs your attention" "$tmp/notification-args"
check "Notification appends the message" grep -q "Claude is waiting" "$tmp/notification-args"
check "Notification uses the Ping sound" grep -qx "Ping" "$tmp/notification-args"

echo "== Deferral to the legacy dotfiles hook =="
mkdir -p "$tmp/legacy-claude/hooks"
printf '#!/bin/bash\ntrue\n' > "$tmp/legacy-claude/hooks/notify-macos.sh"
chmod +x "$tmp/legacy-claude/hooks/notify-macos.sh"
printf '{"hooks":{"Stop":[{"hooks":[{"command":"%s"}]}]}}\n' \
  "$tmp/legacy-claude/hooks/notify-macos.sh" > "$tmp/legacy-claude/settings.json"
run_notify '{"hook_event_name":"Stop","cwd":"/tmp/myproj"}' \
  "$tmp/deferred-args" "$tmp/legacy-claude"
check "defers when the dotfiles hook is active" test ! -e "$tmp/deferred-args"

# A stale settings entry whose script is gone must NOT silence the plugin.
rm "$tmp/legacy-claude/hooks/notify-macos.sh"
run_notify '{"hook_event_name":"Stop","cwd":"/tmp/myproj"}' \
  "$tmp/stale-args" "$tmp/legacy-claude"
check "stays active on a stale settings entry" test -s "$tmp/stale-args"

echo "== check-helper.sh =="
helper_hint="$(env CCNOTIFY_BIN="$stub" bash "$plugin_dir/scripts/check-helper.sh")"
if [[ -z "$helper_hint" ]]; then
  echo "ok: silent when the helper is present"
else
  echo "FAIL: silent when the helper is present"
  failures=$((failures + 1))
fi

echo
if [[ "$failures" -gt 0 ]]; then
  echo "$failures check(s) failed."
  exit 1
fi
echo "All checks passed."
