#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: check_site.sh <url> [timeout_seconds] [log_file]

Examples:
  check_site.sh https://example.com
  check_site.sh http://127.0.0.1:8000 5 /tmp/site-monitor.log
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

url="${1:-}"
timeout="${2:-10}"
log_file="${3:-}"

if [[ -z "$url" ]]; then
  echo "ERROR: URL is required." >&2
  usage >&2
  exit 2
fi

if [[ ! "$timeout" =~ ^[1-9][0-9]*$ ]]; then
  echo "ERROR: timeout must be a positive integer." >&2
  exit 2
fi

if [[ -n "$log_file" ]]; then
  log_dir="$(dirname -- "$log_file")"
  if ! mkdir -p -- "$log_dir"; then
    echo "ERROR: unable to create log directory: $log_dir" >&2
    exit 2
  fi
fi

timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
if curl -fsS --max-time "$timeout" --connect-timeout "$timeout" -o /dev/null "$url"; then
  line="$timestamp UP $url"
  echo "$line"
  if [[ -n "$log_file" ]]; then
    printf '%s\n' "$line" >> "$log_file"
  fi
  exit 0
else
  line="$timestamp DOWN $url"
  echo "$line" >&2
  if [[ -n "$log_file" ]]; then
    printf '%s\n' "$line" >> "$log_file"
  fi
  exit 1
fi
