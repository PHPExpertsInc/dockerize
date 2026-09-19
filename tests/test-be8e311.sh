#!/usr/bin/env bash
#####################################################################
# Commit be8e311: Fixed the installer's port reservation and 8.5 -full
# mismatch.
#
# 1. findFirstAvailablePort() must honour excluded (reserved) ports so
#    the dynamic first port cannot collide with a later fixed 80xx port.
# 2. choosePHPVersions() must only append -full for versions the pipeline
#    actually builds (PHP 8.0-8.5), and skip the rest.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

SCRIPT="$ROOT/install.php"
[ -f "$SCRIPT" ] || { bad "missing install.php"; printf '%sFAILED%s\n' "$RED" "$RESET"; exit 1; }

PHP_BIN="${PHP_BIN:-/usr/bin/php}"
if [ ! -x "$PHP_BIN" ]; then
    PHP_BIN="$(command -v php || true)"
fi
if [ -z "$PHP_BIN" ] || [ ! -x "$PHP_BIN" ]; then
    bad "could not find a native PHP interpreter (set PHP_BIN)"
    printf '%sFAILED%s: be8e311 installer port reservation / -full guard\n' "$RED" "$RESET"
    exit 1
fi

# --- 1. Static wiring: installPHP reserves the fixed ports and passes them.
grep -q 'function findFirstAvailablePort(int $initialPort, array $excludedPorts = \[\])' "$SCRIPT" \
    || bad "findFirstAvailablePort() does not accept excluded ports"
grep -q 'findFirstAvailablePort(8000, $reservedPorts)' "$SCRIPT" \
    || bad "installPHP() does not pass the reserved ports to findFirstAvailablePort()"

# --- 2. Behavioural: the real function must skip excluded ports.
FUNC="$(sed -n '/^function findFirstAvailablePort/,/^}/p' "$SCRIPT")"
if [ -z "$FUNC" ]; then
    bad "could not extract findFirstAvailablePort()"
else
    result="$(printf '%s\n' "$FUNC" | "$PHP_BIN" -r 'eval(stream_get_contents(STDIN)); echo findFirstAvailablePort(8000, range(8000, 8999));' 2>/dev/null | tail -n1)"
    if ! printf '%s' "$result" | grep -qE '^[0-9]+$'; then
        bad "findFirstAvailablePort() did not return a port: '$result'"
    elif [ "$result" -le 8999 ]; then
        bad "findFirstAvailablePort() ignored the excluded ports (got $result)"
    fi
fi

# --- 3. Static: every 8.0-8.5 -full image must actually be built.
CI="$ROOT/docker/build-images.sh"
CF="$ROOT/docker/build-full-images.sh"
EB="$ROOT/docker/images/ext-builder/Dockerfile"
grep -q 'FULL_PHP_VERSIONS="8.0 8.1 8.2 8.3 8.4 8.5"' "$CI" \
    || bad "build-images.sh FULL_PHP_VERSIONS does not include 8.5"
grep -q 'PHP_VERSIONS="8.0 8.1 8.2 8.3 8.4 8.5"' "$CF" \
    || bad "build-full-images.sh PHP_VERSIONS does not include 8.5"
grep -q 'php8.5-cli' "$EB" \
    || bad "ext-builder does not install php8.5-cli"
grep -q 'php8.5-dev' "$EB" \
    || bad "ext-builder does not install php8.5-dev"
grep -qE "\\['8\\.0', '8\\.1', '8\\.2', '8\\.3', '8\\.4', '8\\.5'\\]" "$SCRIPT" \
    || bad "install.php fullImageVersions() does not include 8.5"

# --- 4. End-to-end: -full selections.
run_install() {
    local label="$1" input="$2" sandbox rc
    sandbox="$(mktemp -d)"
    (
        cd "$sandbox" || exit 1
        printf '%b' "$input" | "$PHP_BIN" "$SCRIPT" > install.out 2>&1
    )
    rc=$?
    LAST_SANDBOX="$sandbox"
    LAST_RC="$rc"
}

# 8.5 (1) + 8.4 (2), full: both full images must be requested.
run_install "mixed" '1 2\ny\n0\n'
if [ "$LAST_RC" -ne 0 ]; then
    bad "mixed 8.5/8.4 full install exited $LAST_RC"
    sed 's/^/    /' "$LAST_SANDBOX/install.out" >&2
else
    grep -q 'nginx-php8.5-full' "$LAST_SANDBOX/docker-compose.yml" \
        || bad "installer did not request the (now supported) nginx-php8.5-full"
    grep -q 'nginx-php8.4-full' "$LAST_SANDBOX/docker-compose.yml" \
        || bad "installer dropped the valid nginx-php8.4-full reference"
fi
rm -rf "$LAST_SANDBOX"

# 8.5 alone, full: must succeed now that the image is built.
run_install "only85" '1\ny\n0\n'
if [ "$LAST_RC" -ne 0 ]; then
    bad "8.5-only -full selection was rejected (exit $LAST_RC)"
    sed 's/^/    /' "$LAST_SANDBOX/install.out" >&2
elif ! grep -q 'nginx-php8.5-full' "$LAST_SANDBOX/docker-compose.yml"; then
    bad "8.5-only -full selection did not request nginx-php8.5-full"
fi
rm -rf "$LAST_SANDBOX"

# Pre-8.0 versions still have no -full image: the guard must skip them.
run_install "legacy" '7 2\ny\n0\n'
if [ "$LAST_RC" -ne 0 ]; then
    bad "7.4/8.4 full install exited $LAST_RC"
    sed 's/^/    /' "$LAST_SANDBOX/install.out" >&2
else
    if grep -q 'nginx-php7.4-full' "$LAST_SANDBOX/docker-compose.yml"; then
        bad "installer requested an unsupported nginx-php7.4-full"
    fi
    grep -q 'nginx-php8.4-full' "$LAST_SANDBOX/docker-compose.yml" \
        || bad "installer dropped nginx-php8.4-full when 7.4 was skipped"
fi
rm -rf "$LAST_SANDBOX"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: be8e311 installer reserves ports and builds 8.0-8.5 -full\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: be8e311 installer port reservation / -full guard\n' "$RED" "$RESET"
    exit 1
fi
