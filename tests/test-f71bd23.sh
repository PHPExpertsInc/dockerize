#!/usr/bin/env bash
#####################################################################
# Commit f71bd23: Guarded the cleanup trap against set -e aborts.
#
# The web-debug cleanup() killed/wait'ed on child PIDs without
# tolerating failures. Under `set -e` a failed kill or wait aborted
# the trap before it could exit cleanly. Verify the guards exist and
# that cleanup() exits 0 even when the children are already gone.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

SCRIPT="$ROOT/docker/images/web-debug/entrypoint.sh"
[ -f "$SCRIPT" ] || { bad "missing docker/images/web-debug/entrypoint.sh"; printf '%sFAILED%s\n' "$RED" "$RESET"; exit 1; }

CLEANUP="$(awk '/^cleanup\(\) \{/{f=1} f{print} f && /^\}/{exit}' "$SCRIPT")"
[ -n "$CLEANUP" ] || bad "could not find cleanup() in web-debug/entrypoint.sh"

printf '%s\n' "$CLEANUP" | grep -q 'kill -TERM .*|| true' \
    || bad "cleanup() does not guard the kill against 'set -e'"
printf '%s\n' "$CLEANUP" | grep -q 'wait .*|| true' \
    || bad "cleanup() does not guard the wait against 'set -e'"

# Exercise the extracted cleanup() under `set -e` with PIDs that are
# not children, which is what happens during a normal shutdown.
if [ -n "$CLEANUP" ]; then
    harness="$(mktemp)"
    {
        echo '#!/usr/bin/env bash'
        echo 'set -euo pipefail'
        echo 'PHP_PID=999991'
        echo 'NGINX_PID=999992'
        printf '%s\n' "$CLEANUP"
        echo 'cleanup'
    } > "$harness"
    chmod +x "$harness"

    if bash "$harness" >/dev/null 2>&1; then
        :
    else
        bad "cleanup() aborts under 'set -e' when the children are gone"
    fi
    rm -f "$harness"
fi

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: f71bd23 cleanup trap is guarded against set -e\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: f71bd23 cleanup trap guard\n' "$RED" "$RESET"
    exit 1
fi
