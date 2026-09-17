#!/usr/bin/env bash
#####################################################################
# Commit 631fc5f: Routed nginx logs to stdout/stderr.
#
# The distroless images have no /dev/log, so nginx's syslog target
# silently dropped all access and error logs. Verify nginx now logs to
# /dev/stdout and /dev/stderr and that syslog is gone.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

check_nginx_conf() {
    local rel="$1" f="$ROOT/$1"
    [ -f "$f" ] || { bad "missing $rel"; return; }
    grep -q 'access_log /dev/stdout;' "$f" || bad "$rel: access_log is not /dev/stdout"
    grep -q 'error_log /dev/stderr;'  "$f" || bad "$rel: error_log is not /dev/stderr"
    if grep -q 'syslog:server=unix:/dev/log' "$f"; then
        bad "$rel: still routes logs to the (missing) /dev/log syslog socket"
    fi
}

check_dockerfile() {
    local rel="$1" f="$ROOT/$1"
    [ -f "$f" ] || { bad "missing $rel"; return; }
    grep -q "s!/var/log/nginx/access.log!/dev/stdout!g" "$f" \
        || bad "$rel: sed does not rewrite access.log to /dev/stdout"
    grep -q "s!/var/log/nginx/error.log!/dev/stderr!g" "$f" \
        || bad "$rel: sed does not rewrite error.log to /dev/stderr"
    if grep -q 'syslog:server=unix:/dev/log' "$f"; then
        bad "$rel: still rewrites nginx logs to syslog"
    fi
}

for conf in \
    docker/images/web/nginx.conf \
    docker/images/web-debug/nginx.conf \
    docker/images/web-ioncube/nginx.conf \
    docker/images/web-php8/nginx.conf
do
    check_nginx_conf "$conf"
done

for df in \
    docker/images/web/Dockerfile \
    docker/images/web-debug/Dockerfile \
    docker/images/web-full/Dockerfile \
    docker/images/web-ioncube/Dockerfile \
    docker/images/web-php8/Dockerfile
do
    check_dockerfile "$df"
done

# Prove the sed expressions actually transform a stock nginx.conf.
fixture="$(mktemp)"
cat > "$fixture" <<'EOF'
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log;
EOF
sed -i 's!/var/log/nginx/access.log!/dev/stdout!g' "$fixture"
sed -i 's!/var/log/nginx/error.log!/dev/stderr!g' "$fixture"
grep -q 'access_log /dev/stdout;' "$fixture" || bad "sed fixture: access log not rewritten"
grep -q 'error_log /dev/stderr;'  "$fixture" || bad "sed fixture: error log not rewritten"
rm -f "$fixture"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 631fc5f routes nginx logs to stdout/stderr\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 631fc5f nginx log routing\n' "$RED" "$RESET"
    exit 1
fi
