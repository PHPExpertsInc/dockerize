#!/usr/bin/env bash
#####################################################################
# Commit b1f6af4: Detected missing ldd dependencies and aborted
# incomplete image builds.
#
# Previously `ldd` output with "not found" entries was silently
# dropped, producing broken distroless images. Verify the scripts now
# detect unresolvable dependencies and abort with a non-zero status.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

make_fake_ldd() {
    local dir="$1" mode="$2"
    if [ "$mode" = "missing" ]; then
        cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
/usr/bin/ldd "$1" 2>/dev/null
echo "libtotally_missing.so.1 => not found"
EOF
    else
        cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
exec /usr/bin/ldd "$1"
EOF
    fi
    chmod +x "$dir/ldd"
}

check_script() {
    local script="$1" label="$2"
    local tmp mockbin sandbox target
    tmp="$(mktemp -d)"; mockbin="$tmp/bin"; sandbox="$tmp/run.sh"
    mkdir -p "$mockbin"
    target="/bin/true"

    [ -f "$script" ] || { bad "$label: missing $script"; rm -rf "$tmp"; return; }
    sed "s#/tmp/distroless#$tmp/distroless#g" "$script" > "$sandbox"

    make_fake_ldd "$mockbin" missing
    local err rc
    err="$(PATH="$mockbin:$PATH" bash "$sandbox" "$target" 2>&1 >/dev/null)"
    rc=$?
    if [ "$rc" -eq 3 ]; then
        :
    else
        bad "$label: expected exit 3 for missing dependencies, got $rc"
    fi
    printf '%s' "$err" | grep -q 'Missing library dependencies' \
        || bad "$label: did not report the missing library dependencies"
    printf '%s' "$err" | grep -q 'unresolvable dependencies' \
        || bad "$label: did not abort with an unresolvable-dependency error"

    make_fake_ldd "$mockbin" ok
    err="$(PATH="$mockbin:$PATH" bash "$sandbox" "$target" 2>&1 >/dev/null)"
    rc=$?
    if [ "$rc" -eq 0 ]; then
        :
    else
        bad "$label: healthy dependencies should exit 0, got $rc: $err"
    fi

    rm -rf "$tmp"
}

check_script "$ROOT/docker/images/distroless/grab_files.sh" "distroless/grab_files.sh"
check_script "$ROOT/docker/extract-binaries.sh" "extract-binaries.sh"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: b1f6af4 aborts on missing ldd dependencies\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: b1f6af4 missing dependency detection\n' "$RED" "$RESET"
    exit 1
fi
