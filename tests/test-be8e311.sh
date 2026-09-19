#!/usr/bin/env bash
#####################################################################
# Commit be8e311: Fixed the installer's port reservation and 8.5 -full
# mismatch.
#
# 1. findFirstAvailablePort() must honour excluded (reserved) ports so
#    the dynamic first port cannot collide with a later fixed 80xx port.
# 2. choosePHPVersions() must not emit a -full image reference for PHP
#    8.5 (no such image is built) and must abort when nothing remains.
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
    printf '%sFAILED%s: be8e311 installer port reservation / 8.5 -full guard\n' "$RED" "$RESET"
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

# --- 3. End-to-end: the 8.5 -full guard.
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

# 8.5 (1) + 8.4 (2), full: 8.5 is skipped, 8.4-full remains.
run_install "mixed" '1 2\ny\n0\n'
if [ "$LAST_RC" -ne 0 ]; then
    bad "mixed 8.5/8.4 full install exited $LAST_RC"
    sed 's/^/    /' "$LAST_SANDBOX/install.out" >&2
else
    if grep -q 'nginx-php8.5-full' "$LAST_SANDBOX/docker-compose.yml"; then
        bad "installer still references the non-existent nginx-php8.5-full"
    fi
    grep -q 'nginx-php8.4-full' "$LAST_SANDBOX/docker-compose.yml" \
        || bad "installer dropped the valid nginx-php8.4-full reference"
fi
rm -rf "$LAST_SANDBOX"

# 8.5 alone, full: must abort instead of writing an invalid compose file.
run_install "only85" '1\ny\n0\n'
if [ "$LAST_RC" -eq 0 ]; then
    bad "installer accepted an 8.5-only -full selection"
fi
if [ -f "$LAST_SANDBOX/docker-compose.yml" ]; then
    bad "installer wrote a compose file for an unsupported 8.5-only -full selection"
fi
rm -rf "$LAST_SANDBOX"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: be8e311 installer reserves ports and guards unsupported -full versions\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: be8e311 installer port reservation / 8.5 -full guard\n' "$RED" "$RESET"
    exit 1
fi
