#!/usr/bin/env bash
#####################################################################
# Commit 4dd4071: Exec'd passthrough commands in the entrypoints for
# signal handling.
#
# Passing a command previously ran it as a child, so the entrypoint
# shell stayed PID 1 and commands missed signals. Verify the
# passthrough commands now replace the shell via exec.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

assert_exec_replaces_shell() {
    local label="$1" script="$2"
    shift 2
    [ -f "$ROOT/$script" ] || { bad "$label: missing $script"; return; }

    bash "$ROOT/$script" "$@" &
    local pid=$!
    sleep 0.5
    local comm
    comm="$(cat "/proc/$pid/comm" 2>/dev/null || echo gone)"
    kill -TERM "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true

    if [ "$comm" = "bash" ]; then
        bad "$label: passthrough command was not exec'd (process is still bash)"
    fi
}

# PHP base images exec php/composer/sh/bash or fall through to php.
for f in docker/images/base/entrypoint.sh docker/images/base-php8/entrypoint.sh; do
    grep -q 'exec /usr/bin/php' "$ROOT/$f"       || bad "$f: does not exec /usr/bin/php"
    grep -q 'exec "\$@"' "$ROOT/$f"              || bad "$f: does not exec passthrough commands"
    grep -q 'exec /usr/bin/php "\$@"' "$ROOT/$f" || bad "$f: does not exec php with arguments"
    if grep -qxE '[[:space:]]*"\$@"' "$ROOT/$f"; then
        bad "$f: still has the un-exec'd '\$@' passthrough"
    fi
done

assert_exec_replaces_shell "base"      docker/images/base/entrypoint.sh      sh -c 'sleep 5'
assert_exec_replaces_shell "base-php8" docker/images/base-php8/entrypoint.sh sh -c 'sleep 5'

# Web images exec any passthrough command.
for f in \
    docker/images/web/entrypoint.sh \
    docker/images/web-full/entrypoint.sh \
    docker/images/web-debug/entrypoint.sh \
    docker/images/web-ioncube/entrypoint.sh
do
    grep -q 'exec "\$@"' "$ROOT/$f" || bad "$f: does not exec passthrough commands"
    if grep -qxE '[[:space:]]*"\$@"' "$ROOT/$f"; then
        bad "$f: still has the un-exec'd '\$@' passthrough"
    fi
    assert_exec_replaces_shell "$(basename "$(dirname "$f")")" "$f" sleep 5
done

if [ "$FAILED" -eq 0 ]; then
    printf "%sPASSED%s: 4dd4071 passthrough commands are exec'd\\n" "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 4dd4071 entrypoint exec passthrough\n' "$RED" "$RESET"
    exit 1
fi
