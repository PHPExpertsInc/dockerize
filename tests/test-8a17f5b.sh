#!/usr/bin/env bash
#####################################################################
# Commit 8a17f5b: Preserved child exit status and cleaned up
# survivors on web entrypoints.
#
# The web entrypoints always exited 0 and could leave the surviving
# service running. Verify that when a child dies the entrypoint exits
# with the child's status and that the surviving child is terminated.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

run_entrypoint() {
    local label="$1" script="$2" child_status="$3"
    local tmp mockbin start end rc elapsed_ms comm
    tmp="$(mktemp -d)"; mockbin="$tmp/bin"; mkdir -p "$mockbin"

    cat > "$mockbin/php-fpm" <<EOF
#!/usr/bin/env bash
sleep 0.2
exit $child_status
EOF
    cat > "$mockbin/nginx" <<'EOF'
#!/usr/bin/env bash
trap 'exit 0' TERM INT
while :; do sleep 0.05; done
EOF
    chmod +x "$mockbin/php-fpm" "$mockbin/nginx"

    start=$(date +%s%N)
    PATH="$mockbin:$PATH" bash "$ROOT/$script" >"$tmp/out" 2>"$tmp/err"
    rc=$?
    end=$(date +%s%N)
    elapsed_ms=$(( (end - start) / 1000000 ))

    if [ "$rc" -eq "$child_status" ]; then
        :
    else
        bad "$label: entrypoint exited $rc, expected child status $child_status"
    fi

    if [ "$elapsed_ms" -gt 5000 ]; then
        bad "$label: took ${elapsed_ms}ms; the surviving service was not terminated"
    fi

    for pid in $(pgrep -f "$mockbin/nginx" 2>/dev/null || true); do
        bad "$label: leaked a surviving service process (pid $pid)"
        kill -KILL "$pid" 2>/dev/null || true
    done

    rm -rf "$tmp"
}

for f in docker/images/web-full/entrypoint.sh docker/images/web-debug/entrypoint.sh; do
    [ -f "$ROOT/$f" ] || { bad "missing $f"; continue; }
    grep -q 'local status="\${1:-0}"' "$ROOT/$f" || bad "$f: cleanup does not accept a status"
    grep -q 'exit "\$status"'          "$ROOT/$f" || bad "$f: cleanup does not preserve the status"
    grep -q "trap 'cleanup' SIGTERM SIGINT" "$ROOT/$f" || bad "$f: trap is not guarded"
    grep -q 'wait -n "\$PHP_PID" "\$NGINX_PID" || status=\$?' "$ROOT/$f" \
        || bad "$f: does not capture the first child's exit status"

    run_entrypoint "web-full (exit 7)"  docker/images/web-full/entrypoint.sh  7
    run_entrypoint "web-debug (exit 9)" docker/images/web-debug/entrypoint.sh 9
done

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 8a17f5b preserves child status and cleans up survivors\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 8a17f5b web entrypoint lifecycle\n' "$RED" "$RESET"
    exit 1
fi
