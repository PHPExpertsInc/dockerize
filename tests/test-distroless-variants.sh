#!/usr/bin/env bash
#####################################################################
# Distroless variant smoke tests (IG-9).
#
# The -debug and -full variants are built by pointing the same
# distroless gather mechanism at a different fat builder, so a change
# there can silently drop the extension the variant exists for (xdebug
# for -debug, the long tail of bundled extensions for -full). Static
# checks cannot catch that, so exercise the real images.
#
# The tests are image-driven: every matching phpexperts/php and
# phpexperts/web variant that is present locally is smoke-tested, and
# absent ones are reported as skipped. When Docker is unavailable the
# whole run is skipped rather than failed, so the suite stays usable on
# hosts that only lint the shell.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
YELLOW=$'\033[33m'
RESET=$'\033[0m'
FAILED=0
SKIPPED=0
TESTED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }
skip() { SKIPPED=$((SKIPPED + 1)); printf '  %s[skip]%s %s\n' "$YELLOW" "$RESET" "$1"; }

# Tear down any web container still standing if the script is interrupted.
SMOKE_CONTAINERS=""
cleanup() {
    local c
    for c in $SMOKE_CONTAINERS; do
        docker rm -f "$c" >/dev/null 2>&1 || true
    done
}
trap cleanup EXIT

# Web checks need curl on the host; skip them rather than fail without it.
HAVE_CURL=1
if ! command -v curl >/dev/null 2>&1; then
    HAVE_CURL=0
    skip "curl is not installed; web variants will not be checked"
fi

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
    printf '%sPASSED%s: distroless variant smoke tests (skipped: Docker unavailable)\n' "$GREEN" "$RESET"
    exit 0
fi

# List every locally present image tag matching a repository prefix.
list_tags() {
    docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -E "$1" | sort -u || true
}

# Run a command inside an image, swallowing stderr noise (xdebug et al.).
in_image() {
    local tag="$1"; shift
    docker run --rm --entrypoint sh "$tag" -c "$*" 2>/dev/null
}

# Sorted, header-free module list for `php -m` parity.
module_list() {
    local tag="$1"
    docker run --rm "$tag" php -m 2>/dev/null \
        | grep -E '^[A-Za-z]' | sort -u
}

#####################################################################
# CLI variants
#####################################################################
check_cli_debug() {
    local tag="$1" ver="${1#phpexperts/php:}"; ver="${ver%-debug}"
    local mods loaded pv mode
    TESTED=$((TESTED + 1))

    mods="$(docker run --rm "$tag" php -m 2>/dev/null)"
    if [ -z "$mods" ]; then
        bad "$tag: 'php -m' produced no output"
        return
    fi

    # The whole reason this variant exists.
    grep -qi '^xdebug$' <<<"$mods" \
        || bad "$tag: xdebug is not in the module list"

    loaded="$(in_image "$tag" 'php -r "echo extension_loaded(\"xdebug\") ? \"yes\" : \"no\";"')"
    [ "$loaded" = "yes" ] || bad "$tag: extension_loaded('xdebug') returned '$loaded'"

    mode="$(in_image "$tag" 'php -r "echo (string) ini_get(\"xdebug.mode\");"')"
    [ -n "$mode" ] || bad "$tag: xdebug.mode is empty (the ini did not survive extraction)"

    pv="$(in_image "$tag" 'php -r "echo PHP_VERSION;"')"
    case "$pv" in
        "$ver".*) ;;
        *) bad "$tag: PHP_VERSION '$pv' does not match the '$ver' tag" ;;
    esac
}

check_cli_full() {
    local tag="$1" ver="${1#phpexperts/php:}"; ver="${ver%-full}"
    local ext mods fat dist
    TESTED=$((TESTED + 1))

    mods="$(docker run --rm "$tag" php -m 2>/dev/null)"
    if [ -z "$mods" ]; then
        bad "$tag: 'php -m' produced no output"
        return
    fi

    # Extensions the -full image is sold on (README) plus a broad sample
    # of the bundled set; any one missing means the grab dropped a lib.
    for ext in imap ldap pspell redis snmp xmlrpc uuid gd mysqli pdo_pgsql \
               pgsql soap zip intl imagick memcached igbinary msgpack ssh2; do
        grep -qix "$ext" <<<"$mods" \
            || bad "$tag: bundled extension '$ext' is missing"
    done

    # Strongest check: module-for-module parity with the fat builder that
    # was slimmed. The builder is removed after a full pipeline run, so
    # only run parity when it is still around.
    fat="phpexperts/php-ubuntu:${ver}-full"
    if docker image inspect "$fat" >/dev/null 2>&1; then
        dist="$(module_list "$tag")"
        fat="$(module_list "$fat")"
        if [ "$fat" != "$dist" ]; then
            bad "$tag: module list differs from the fat builder"
            diff <(printf '%s\n' "$fat") <(printf '%s\n' "$dist") \
                | sed 's/^/    /' >&2
        fi
    else
        skip "$tag: fat builder phpexperts/php-ubuntu:${ver}-full absent, parity not checked"
    fi
}

#####################################################################
# Web variants
#####################################################################
# Start the image the way the installer does (app at /var/www, the
# project's docker/web at /etc/nginx/custom), serve a probe, and tear
# down.
check_web() {
    local tag="$1" base ver variant name tmpdir port rc code body marker
    TESTED=$((TESTED + 1))

    base="${tag#phpexperts/web:nginx-php}"
    case "$base" in
        *-debug) variant=debug; ver="${base%-debug}" ;;
        *-full)  variant=full;  ver="${base%-full}" ;;
        *)       variant=standard; ver="$base" ;;
    esac

    name="dockerize-smoke-web-$$-$RANDOM"
    tmpdir="$(mktemp -d)"
    mkdir -p "$tmpdir/public"
    cat > "$tmpdir/public/index.php" <<'PHP'
<?php
echo 'V=' . PHP_VERSION;
echo ';X=' . (extension_loaded('xdebug') ? '1' : '0');
PHP
    chmod -R 755 "$tmpdir"

    docker rm -f "$name" >/dev/null 2>&1 || true
    if ! docker run -d --rm --name "$name" -p 127.0.0.1::80 \
            -v "$tmpdir:/var/www" \
            -v "$ROOT/docker/web:/etc/nginx/custom" \
            "$tag" >/dev/null 2>&1; then
        bad "$tag: container failed to start"
        rm -rf "$tmpdir"
        return
    fi
    SMOKE_CONTAINERS="$SMOKE_CONTAINERS $name"

    port="$(docker port "$name" 80/tcp 2>/dev/null | head -n1 | sed 's/.*://')"
    if [ -z "$port" ]; then
        bad "$tag: could not resolve the published port"
        docker rm -f "$name" >/dev/null 2>&1
        rm -rf "$tmpdir"
        return
    fi

    # Poll until nginx + php-fpm are answering.
    rc=1
    for _ in $(seq 1 30); do
        code="$(curl -s -m 2 -o "$tmpdir/body" -w '%{http_code}' \
            "http://127.0.0.1:$port/index.php" 2>/dev/null)"
        if [ "$code" = "200" ]; then rc=0; break; fi
        sleep 0.5
    done

    if [ "$rc" -ne 0 ]; then
        bad "$tag: the web server never returned HTTP 200 (last: ${code:-none})"
        docker logs "$name" 2>&1 | tail -n 20 | sed 's/^/    /' >&2
    else
        body="$(cat "$tmpdir/body")"
        served="${body#V=}"; served="${served%%;*}"
        case "$served" in
            "$ver".*) ;;
            *) bad "$tag: served PHP_VERSION '$served' does not match the '$ver' tag ('$body')" ;;
        esac
        if [ "$variant" = "debug" ]; then
            case "$body" in
                *";X=1"*) ;;
                *) bad "$tag: xdebug is not loaded under PHP-FPM ('$body')" ;;
            esac
        fi
    fi

    # The /VERSION marker distinguishes the variants at runtime. Images
    # built before the marker was added (standard variants only) are
    # skipped rather than failed; debug/full must always carry it.
    marker="$(docker exec "$name" cat /VERSION 2>/dev/null)"
    case "$variant" in
        debug) [ "$marker" = "${ver}-debug" ] || bad "$tag: /VERSION is '$marker', expected '${ver}-debug'" ;;
        full)  [ "$marker" = "${ver}-full" ]  || bad "$tag: /VERSION is '$marker', expected '${ver}-full'" ;;
        *)     if [ -z "$marker" ]; then
                   skip "$tag: /VERSION marker absent (pre-marker image), not checked"
               else
                   [ "$marker" = "$ver" ] || bad "$tag: /VERSION is '$marker', expected '$ver'"
               fi ;;
    esac

    # Both long-running services must actually be up. Capture the process
    # table first: piping straight into `grep -q` would SIGPIPE `docker top`
    # and trip `pipefail` even on a successful match.
    local topline
    topline="$(docker top "$name" 2>/dev/null || true)"
    grep -q 'php-fpm' <<<"$topline" \
        || bad "$tag: php-fpm is not running"
    grep -q 'nginx' <<<"$topline" \
        || bad "$tag: nginx is not running"

    docker rm -f "$name" >/dev/null 2>&1 || true
    rm -rf "$tmpdir"
}

#####################################################################
# Discover and exercise whatever variant images exist locally.
#####################################################################
mapfile -t CLI_DEBUG < <(list_tags '^phpexperts/php:[0-9]+\.[0-9]+-debug$')
mapfile -t CLI_FULL  < <(list_tags '^phpexperts/php:[0-9]+\.[0-9]+-full$')
mapfile -t WEB_TAGS  < <(list_tags '^phpexperts/web:nginx-php[0-9]+\.[0-9]+(-debug|-full)?$')

for tag in "${CLI_DEBUG[@]}"; do [ -n "$tag" ] && check_cli_debug "$tag"; done
for tag in "${CLI_FULL[@]}";  do [ -n "$tag" ] && check_cli_full  "$tag"; done
if [ "$HAVE_CURL" -eq 1 ]; then
    for tag in "${WEB_TAGS[@]}"; do [ -n "$tag" ] && check_web "$tag"; done
fi

if [ "$TESTED" -eq 0 ]; then
    printf '%sPASSED%s: distroless variant smoke tests (skipped: no variant images built)\n' "$GREEN" "$RESET"
    exit 0
fi

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: %d distroless variant image(s) smoke-tested (%d check(s) skipped)\n' \
        "$GREEN" "$RESET" "$TESTED" "$SKIPPED"
else
    printf '%sFAILED%s: distroless variant smoke tests (%d tested, %d skipped)\n' \
        "$RED" "$RESET" "$TESTED" "$SKIPPED"
    exit 1
fi
