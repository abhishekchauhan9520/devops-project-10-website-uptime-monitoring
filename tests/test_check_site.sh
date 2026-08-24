#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/monitor/check_site.sh"
TMP_DIR="$(mktemp -d)"
PORT="$(python3 - <<'PY'
import socket
s=socket.socket()
s.bind(('127.0.0.1', 0))
print(s.getsockname()[1])
s.close()
PY
)"
SERVER_PID=""
cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -rf -- "$TMP_DIR"
}
trap cleanup EXIT

python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$ROOT_DIR" >/dev/null 2>&1 &
SERVER_PID=$!
for _ in {1..20}; do
  if curl -fsS --max-time 1 -o /dev/null "http://127.0.0.1:$PORT/README.md"; then
    break
  fi
  sleep 0.1
done

LOG_FILE="$TMP_DIR/monitor.log"
output="$($SCRIPT "http://127.0.0.1:$PORT/README.md" 3 "$LOG_FILE")"
grep -q 'UP http://127.0.0.1:' <<<"$output"
grep -q ' UP ' "$LOG_FILE"

if "$SCRIPT" "http://127.0.0.1:1/unavailable" 1 "$LOG_FILE" >/dev/null 2>&1; then
  echo "Expected failed request to return exit code 1" >&2
  exit 1
fi
grep -q ' DOWN ' "$LOG_FILE"

if "$SCRIPT" >/dev/null 2>&1; then
  echo "Expected missing URL to fail" >&2
  exit 1
else
  status=$?
  [[ "$status" -eq 2 ]]
fi

"$SCRIPT" --help >/dev/null
printf '%s\n' "All uptime-monitor tests passed."
