#!/usr/bin/env bash
#####################################################################
# Commit d375c97: Copied the /VERSION marker into the distroless web
# images.
#
# The web images build nginx/php-fpm in an intermediate stage that
# writes the PHP version to /VERSION. The final stage previously copied
# only /tmp/distroless and the entrypoint, so the marker was dropped and
# the shipped image no longer exposed it. Verify every final stage
# carries /VERSION forward and that the intermediate writes the expected
# variant suffix (plain, -debug or -full).
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

# Print only the lines belonging to the final (shipped) stage.
final_stage() {
    awk '/^FROM /{buf=""; seen=1} seen{buf=buf $0 "\n"} END{printf "%s", buf}' "$1"
}

check_image() {
    local label="$1" suffix="$2"
    local file marker final
    file="$ROOT/docker/images/$label/Dockerfile"
    [ -f "$file" ] || { bad "$label: missing $file"; return; }

    marker="$(grep -E 'echo .*VERSION' "$file" | head -n1)"
    if ! printf '%s' "$marker" | grep -qF '/VERSION'; then
        bad "$label: intermediate stage never writes /VERSION"
    fi
    if [ -n "$suffix" ]; then
        printf '%s' "$marker" | grep -qF -- '${PHP_VERSION}' \
            || bad "$label: marker does not interpolate \${PHP_VERSION}"
        printf '%s' "$marker" | grep -qF -- "$suffix" \
            || bad "$label: marker is not the '$suffix' variant"
    fi

    final="$(final_stage "$file")"
    # Either copied explicitly from the intermediate stage, or written
    # under /tmp/distroless so that `COPY /tmp/distroless /` carries it.
    if printf '%s' "$final" | grep -qE 'COPY[[:space:]]+--from=intermediate[[:space:]]+/VERSION[[:space:]]+/VERSION'; then
        :
    elif grep -qE '(>|tee)[[:space:]]+/tmp/distroless/VERSION' "$file"; then
        :
    else
        bad "$label: /VERSION is not copied into the final image"
    fi
}

check_image web ""
check_image web-debug "-debug"
check_image web-full "-full"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: d375c97 web images carry the /VERSION marker\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: d375c97 web image /VERSION marker\n' "$RED" "$RESET"
    exit 1
fi
