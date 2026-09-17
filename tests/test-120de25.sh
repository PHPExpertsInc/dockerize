#!/usr/bin/env bash
#####################################################################
# Commit 120de25: Removed the premature library copy from the
# distroless scripts.
#
# The early `if [ -x "$1" ]` block copied libraries into
# /tmp/distroless/usr/lib/ before the skeleton mkdir created that
# directory, so the first invocation failed. Verify the scripts can
# bootstrap their destination from scratch without errors.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

run_first_invocation() {
    local script="$1" label="$2"
    local tmp dest target
    tmp="$(mktemp -d)"
    dest="$tmp/distroless"
    target="/bin/true"

    [ -f "$script" ] || { bad "$label: missing $script"; rm -rf "$tmp"; return; }

    sed "s#/tmp/distroless#$dest#g" "$script" > "$tmp/run.sh"

    local err rc
    err="$(PATH="$PATH" bash "$tmp/run.sh" "$target" 2>&1 >/dev/null)"
    rc=$?

    if [ "$rc" -ne 0 ]; then
        bad "$label: first invocation exited $rc (expected 0): $err"
    fi
    if printf '%s' "$err" | grep -q 'cp:'; then
        bad "$label: first invocation emitted a cp error: $err"
    fi
    if [ ! -d "$dest/usr/lib" ]; then
        bad "$label: skeleton directory was not created"
    fi
    if [ ! -e "$dest$target" ]; then
        bad "$label: target $target was not copied into the skeleton"
    fi

    rm -rf "$tmp"
}

run_first_invocation "$ROOT/docker/images/distroless/grab_files.sh" "distroless/grab_files.sh"
run_first_invocation "$ROOT/docker/images/web/grab_files.sh" "web/grab_files.sh"
run_first_invocation "$ROOT/docker/extract-binaries.sh" "extract-binaries.sh"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 120de25 distroless scripts bootstrap cleanly\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 120de25 premature library copy\n' "$RED" "$RESET"
    exit 1
fi
