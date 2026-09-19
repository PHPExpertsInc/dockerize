#!/usr/bin/env bash
#####################################################################
# Commit 4ec31a7: Fixed -full version and port handling in install.php.
#
# installPHP() derived the compose service name and host port from the
# selected image tag by stripping only "-debug" and the dots. A "-full"
# tag therefore produced a port such as "8083-full", which fatally
# crashed the typed AvailablePort::$PORT int property as soon as two or
# more -full versions were selected.
#
# Drive the real installer with piped answers and verify that the second
# selected version gets a clean service name and a numeric host port,
# while the image tag keeps its variant suffix.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

# bin/php shells out to Docker, so resolve a native interpreter instead.
PHP_BIN="${PHP_BIN:-/usr/bin/php}"
if [ ! -x "$PHP_BIN" ]; then
    PHP_BIN="$(command -v php || true)"
fi
if [ -z "$PHP_BIN" ] || [ ! -x "$PHP_BIN" ]; then
    bad "could not find a native PHP interpreter (set PHP_BIN)"
    printf '%sFAILED%s: 4ec31a7 install.php -full port derivation\n' "$RED" "$RESET"
    exit 1
fi

# $1 = variant suffix (full/debug), $2 = newline-escaped stdin answers.
run_install() {
    local suffix="$1" input="$2" sandbox rc mapping value
    sandbox="$(mktemp -d)"

    (
        cd "$sandbox" || exit 1
        printf '%b' "$input" | "$PHP_BIN" "$ROOT/install.php" > install.out 2>&1
    )
    rc=$?

    if [ "$rc" -ne 0 ]; then
        bad "$suffix: install.php exited $rc"
        sed 's/^/    /' "$sandbox/install.out" >&2
        rm -rf "$sandbox"
        return 1
    fi

    if [ ! -f "$sandbox/docker-compose.yml" ]; then
        bad "$suffix: docker-compose.yml was not generated"
        rm -rf "$sandbox"
        return 1
    fi

    # The second selected version (8.3) must map to the clean service name
    # web83 and the numeric port 8083.
    grep -qE '^  web83:$' "$sandbox/docker-compose.yml" \
        || bad "$suffix: missing clean service name 'web83'"

    grep -qE '^[[:space:]]*-[[:space:]]*8083:80[[:space:]]*$' "$sandbox/docker-compose.yml" \
        || bad "$suffix: 8.3 did not map to the fixed port 8083"

    if grep -qE 'web83(-[a-z]+)?:' "$sandbox/docker-compose.yml" \
        && ! grep -qE '^  web83:$' "$sandbox/docker-compose.yml"; then
        bad "$suffix: service name still carries a variant suffix"
    fi

    # Every published port must be numeric (e.g. "8083:80", never
    # "8083-full:80"). The first service's port is whatever is free from
    # 8000, so only the shape is checked.
    while IFS= read -r mapping; do
        [ -z "$mapping" ] && continue
        value="$(printf '%s' "$mapping" | sed -E 's/^[[:space:]]*-[[:space:]]*([^:]+):80[[:space:]]*$/\1/')"
        case "$value" in
            '' | *[!0-9]*) bad "$suffix: non-numeric host port in '$mapping'" ;;
        esac
    done < <(grep -E '^[[:space:]]*-[[:space:]]*[^:]+:80[[:space:]]*$' "$sandbox/docker-compose.yml")

    # The variant must survive in the image tag.
    grep -qF "nginx-php8.3-${suffix}" "$sandbox/docker-compose.yml" \
        || bad "$suffix: image tag lost its '-${suffix}' suffix"

    rm -rf "$sandbox"
    return 0
}

run_install "full"  '2 3\ny\n0\n'
run_install "debug" '2 3\nn\ny\n0\n'

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 4ec31a7 install.php derives numeric ports for -full/-debug\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 4ec31a7 install.php -full port derivation\n' "$RED" "$RESET"
    exit 1
fi
