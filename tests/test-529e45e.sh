#!/usr/bin/env bash
#####################################################################
# Commit 529e45e: Guarded the web grab_files.sh scripts against
# empty ldd dependencies.
#
# A static or non-ELF executable (and linker scripts such as libc.so)
# produce no output from ldd_deps, so the unquoted command substitution
# left cp with no source operand and failed the build. Verify the web,
# web-debug and web-full scripts tolerate empty dependencies, and that
# they abort with exit 3 when ldd reports unresolvable dependencies.
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
    mkdir -p "$dir"
    case "$mode" in
        empty)
            cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
            ;;
        missing)
            cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
echo "libtotally_missing.so.1 => not found"
EOF
            ;;
        *)
            cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
exec /usr/bin/ldd "$1"
EOF
            ;;
    esac
    chmod +x "$dir/ldd"
}

run_case() {
    local script="$1" label="$2" mode="$3" target="$4" want_rc="$5"
    local tmp mockbin sandbox err rc
    tmp="$(mktemp -d)"; mockbin="$tmp/bin"; sandbox="$tmp/run.sh"

    sed "s#/tmp/distroless#$tmp/distroless#g" "$script" > "$sandbox"
    make_fake_ldd "$mockbin" "$mode"

    err="$(PATH="$mockbin:$PATH" bash "$sandbox" "$target" 2>&1 >/dev/null)"
    rc=$?

    if [ "$rc" -ne "$want_rc" ]; then
        bad "$label [$mode/$target]: expected exit $want_rc, got $rc: $err"
    fi
    if printf '%s' "$err" | grep -q 'missing file operand'; then
        bad "$label [$mode/$target]: cp was left without a source operand: $err"
    fi
    if [ "$mode" = "missing" ]; then
        printf '%s' "$err" | grep -q 'unresolvable dependencies' \
            || bad "$label [$mode/$target]: did not report unresolvable dependencies"
        printf '%s' "$err" | grep -q 'Missing library dependencies' \
            || bad "$label [$mode/$target]: did not list the missing libraries"
    fi

    rm -rf "$tmp"
}

check_script() {
    local script="$1" label="$2"
    local tmp libdir

    run_case "$script" "$label" empty "/bin/true" 0

    tmp="$(mktemp -d)"; libdir="$tmp/libs"; mkdir -p "$libdir"
    printf 'not really an elf\n' > "$libdir/libstatic.so"
    run_case "$script" "$label" empty "$libdir" 0
    rm -rf "$tmp"

    run_case "$script" "$label" missing "/bin/true" 3
}

for label in web web-debug web-full; do
    script="$ROOT/docker/images/$label/grab_files.sh"
    [ -f "$script" ] || { bad "$label: missing $script"; continue; }
    check_script "$script" "$label"
done

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 529e45e web grab_files.sh handles empty ldd deps\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 529e45e web grab_files.sh empty dependency handling\n' "$RED" "$RESET"
    exit 1
fi
