#!/usr/bin/env bash
#####################################################################
# Commit aa369c5: Refreshed the apt index in the extension builder
# before installing deps.
#
# Commit 80a3627 moved the apt lists into a BuildKit cache mount, so
# they are no longer committed to any image layer. The ext-builder
# entrypoint installs each extension's PACKAGES at container runtime and
# never ran `apt-get update`, so a freshly built ext-builder had an empty
# /var/lib/apt/lists and every extension failed with:
#
#     E: Unable to locate package uuid-dev
#
# Verify the entrypoint refreshes the index immediately before the
# install, and (when the built image is available) prove the ordering
# behaviourally with a recording apt-get.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

ENTRYPOINT="$ROOT/docker/images/ext-builder/entrypoint.sh"
DOCKERFILE="$ROOT/docker/images/ext-builder/Dockerfile"

[ -f "$ENTRYPOINT" ] || { bad "missing $ENTRYPOINT"; }
[ -f "$DOCKERFILE" ] || { bad "missing $DOCKERFILE"; }

# --- 1. Static: the update must precede the install.
if [ -f "$ENTRYPOINT" ]; then
    grep -q 'apt-get update' "$ENTRYPOINT" \
        || bad "entrypoint.sh does not run 'apt-get update'"

    update_line="$(grep -n 'apt-get update' "$ENTRYPOINT" | head -n1 | cut -d: -f1)"
    install_line="$(grep -n 'apt-get install' "$ENTRYPOINT" | head -n1 | cut -d: -f1)"
    if [ -z "$update_line" ] || [ -z "$install_line" ]; then
        bad "could not locate the apt-get update/install lines"
    elif [ "$update_line" -ge "$install_line" ]; then
        bad "apt-get update (line $update_line) does not precede apt-get install (line $install_line)"
    fi
fi

# --- 2. The root cause: the Dockerfile no longer bakes the index into
#        the image, which is exactly why the runtime update is needed.
if [ -f "$DOCKERFILE" ]; then
    grep -q 'type=cache,target=/var/lib/apt/lists' "$DOCKERFILE" \
        || bad "ext-builder Dockerfile no longer cache-mounts /var/lib/apt/lists; revisit the runtime update"
fi

# --- 3. Behavioural: on the real image, a recording apt-get must see
#        'update' before 'install'. Skipped when the image is absent.
if command -v docker >/dev/null 2>&1 && docker image inspect phpexperts/ext-builder:latest >/dev/null 2>&1; then
    log="$(docker run --rm --entrypoint sh phpexperts/ext-builder:latest -c '
        mkdir -p /tmp/fake
        cat > /tmp/fake/apt-get <<"FAKE"
#!/bin/sh
echo "$1" >> /tmp/apt.log
[ "$1" = "install" ] && exit 9
exit 0
FAKE
        chmod +x /tmp/fake/apt-get
        PATH=/tmp/fake:$PATH /usr/local/bin/entrypoint.sh uuid >/dev/null 2>&1 || true
        cat /tmp/apt.log 2>/dev/null
    ' 2>/dev/null)"

    first="$(printf '%s\n' "$log" | sed -n '1p')"
    second="$(printf '%s\n' "$log" | sed -n '2p')"
    if [ "$first" != "update" ] || [ "$second" != "install" ]; then
        bad "image entrypoint called apt-get in the wrong order: '${first:-<none>}', '${second:-<none>}'"
    fi
else
    printf '  [skip] phpexperts/ext-builder:latest not present; behavioural check skipped\n'
fi

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: aa369c5 extension builder refreshes apt before installing deps\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: aa369c5 extension builder apt refresh\n' "$RED" "$RESET"
    exit 1
fi
