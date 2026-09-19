#!/usr/bin/env bash
#####################################################################
# Commit 9ab2692: Propagated ldd failures with diagnostics from
# grab_files.sh.
#
# ldd_deps() used to discard ldd's stderr and ignore its exit status, so
# only a literal "not found" token was ever acted on. Any other non-zero
# ldd outcome (corrupt ELF, unreadable file, broken interpreter) produced
# an empty or partial dependency list and the build continued with an
# incomplete distroless image. Verify the helper now surfaces ldd's
# diagnostics and aborts for every non-zero status except the known
# static/non-ELF cases, which still succeed with no dependencies.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

CANON="$ROOT/docker/images/grab_files.sh"
[ -f "$CANON" ] || { bad "missing canonical script: $CANON"; }

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
        static)
            cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
echo "not a dynamic executable" >&2
exit 1
EOF
            ;;
        missing)
            cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
echo "libtotally_missing.so.1 => not found"
EOF
            ;;
        hardfail)
            cat > "$dir/ldd" <<'EOF'
#!/usr/bin/env bash
echo "ldd: $1: cannot read ELF header" >&2
exit 2
EOF
            ;;
        *)
            bad "unknown fake ldd mode: $mode"
            ;;
    esac
    chmod +x "$dir/ldd"
}

run_case() {
    local script="$1" label="$2" mode="$3" want_rc="$4" want_msg="$5"
    local tmp mockbin sandbox err rc
    tmp="$(mktemp -d)"; mockbin="$tmp/bin"; sandbox="$tmp/run.sh"
    sed "s#/tmp/distroless#$tmp/distroless#g" "$script" > "$sandbox"
    make_fake_ldd "$mockbin" "$mode"

    err="$(PATH="$mockbin:$PATH" bash "$sandbox" /bin/true 2>&1 >/dev/null)"
    rc=$?
    if [ "$rc" -ne "$want_rc" ]; then
        bad "$label [$mode]: expected exit $want_rc, got $rc: $err"
    fi
    if [ -n "$want_msg" ]; then
        printf '%s' "$err" | grep -q "$want_msg" \
            || bad "$label [$mode]: missing diagnostic '$want_msg': $err"
    fi
    rm -rf "$tmp"
}

check_script() {
    local script="$1" label="$2"
    # Known static/non-ELF output is a successful empty result.
    run_case "$script" "$label" empty 0 ""
    run_case "$script" "$label" static 0 ""
    # Unresolvable dependencies still abort.
    run_case "$script" "$label" missing 3 "Missing library dependencies"
    # Any other non-zero ldd status must abort, with ldd's own diagnostics.
    run_case "$script" "$label" hardfail 3 "ldd failed"
    run_case "$script" "$label" hardfail 3 "cannot read ELF header"
}

check_script "$CANON" "canonical"
check_script "$ROOT/docker/extract-binaries.sh" "extract-binaries.sh"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: ldd failures are propagated with diagnostics\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: ldd failure propagation\n' "$RED" "$RESET"
    exit 1
fi
