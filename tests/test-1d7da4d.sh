#!/usr/bin/env bash
#####################################################################
# Commit 1d7da4d: Prepared extension tarballs for standalone -full
# builds.
#
# build-full-images.sh <version> skipped prepare_ext_builder, so on a
# clean checkout the gitignored base-full/exts tarballs were missing and
# base-full's COPY failed. Verify the single-version branch calls
# ensure_extensions(), that ensure_extensions prepares when a tarball is
# absent, and that it stays a no-op when the tarball exists.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

SCRIPT="$ROOT/docker/build-full-images.sh"
[ -f "$SCRIPT" ] || { bad "missing docker/build-full-images.sh"; printf '%sFAILED%s\n' "$RED" "$RESET"; exit 1; }

grep -q 'ensure_extensions "\$1"' "$SCRIPT" \
    || bad "the single-version branch does not call ensure_extensions"

FUNC="$(sed -n '/^ensure_extensions() {/,/^}/p' "$SCRIPT")"
if [ -z "$FUNC" ]; then
    bad "could not extract ensure_extensions from build-full-images.sh"
    printf '%sFAILED%s: 1d7da4d standalone -full extension preparation\n' "$RED" "$RESET"
    exit 1
fi

sandbox="$(mktemp -d)"
mkdir -p "$sandbox/ext-builder/deps" "$sandbox/base-full/exts"
: > "$sandbox/ext-builder/deps/uuid.deps"

# $1 = version; prints PREPARED if prepare_ext_builder was invoked.
probe() {
    (
        cd "$sandbox" || exit 1
        prepare_ext_builder() { echo PREPARED; }
        eval "$FUNC"
        ensure_extensions "$1"
    )
}

out="$(probe 8.4)"
printf '%s' "$out" | grep -q PREPARED \
    || bad "did not prepare when the 8.4 extension tarball was missing"

: > "$sandbox/base-full/exts/ext-uuid.8.4.tar.xz"
out="$(probe 8.4)"
if printf '%s' "$out" | grep -q PREPARED; then
    bad "prepared even though the 8.4 extension tarball already exists"
fi

rm -rf "$sandbox"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 1d7da4d standalone -full builds prepare extension tarballs\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 1d7da4d standalone -full extension preparation\n' "$RED" "$RESET"
    exit 1
fi
