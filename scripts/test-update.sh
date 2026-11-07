#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/update.sh"

run_updates() (
  updates=0
  opencode() {
    echo "$*"
    if [ "$2" = update ]; then
      updates=$((updates + 1))
      [ "$updates" -gt "$failures" ]
    fi
  }
  sleep() {
    echo "sleep $1"
  }
  source <(sed '/^cat > /,$d' "$SCRIPT")
)

output="$(failures=0 run_updates)"
[ "$(grep -c '^plugin add ' <<< "$output")" -eq 2 ]
[ "$(grep -c '^plugin update ' <<< "$output")" -eq 2 ]
! grep -q '^sleep ' <<< "$output"

output="$(failures=2 run_updates)"
[ "$(grep -c '^plugin add ' <<< "$output")" -eq 2 ]
[ "$(grep -c '^plugin update ' <<< "$output")" -eq 4 ]
[ "$(grep -c '^sleep 1$' <<< "$output")" -eq 2 ]

if output="$(failures=5 run_updates)"; then
  echo 'Expected persistent update failure to stop the script' >&2
  exit 1
fi
[ "$(grep -c '^plugin add ' <<< "$output")" -eq 1 ]
[ "$(grep -c '^plugin update ' <<< "$output")" -eq 5 ]
[ "$(grep -c '^sleep 1$' <<< "$output")" -eq 4 ]

echo 'Plugin update tests passed'
