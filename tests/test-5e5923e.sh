#!/usr/bin/env bash
#####################################################################
# Commit 5e5923e: Consolidated the three grab_files.sh copies into one
# canonical script.
#
# The distroless, web, web-debug and web-full images each shipped their
# own copy of grab_files.sh, and they had already drifted (the web copies
# created /usr/lib64 and guarded empty ldd deps; distroless did neither).
# docker/extract-binaries.sh was a fourth, further-diverged variant.
#
# Verify the images now share a single canonical script, that the old
# paths are symlinks to it, that every consumer pulls it through the
# BuildKit named build context, and that the canonical script still
# detects unresolvable ldd dependencies.
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

# 1. The canonical script must exist and be a real (non-symlink) file.
if [ ! -f "$CANON" ]; then
    bad "missing canonical script: docker/images/grab_files.sh"
elif [ -L "$CANON" ]; then
    bad "docker/images/grab_files.sh must be the real file, not a symlink"
fi

# 2. Every previously-divergent path must be a symlink resolving to the
#    canonical script, so no copy can drift again.
for rel in \
    docker/images/distroless/grab_files.sh \
    docker/images/web/grab_files.sh \
    docker/images/web-debug/grab_files.sh \
    docker/images/web-full/grab_files.sh \
    docker/extract-binaries.sh
do
    path="$ROOT/$rel"
    if [ ! -L "$path" ]; then
        bad "$rel is not a symlink to the canonical grab_files.sh"
        continue
    fi
    resolved="$(readlink -f "$path")"
    if [ "$resolved" != "$CANON" ]; then
        bad "$rel resolves to $resolved, expected $CANON"
    fi
done

# 2b. There must be exactly one real grab_files.sh implementation under
#     docker/. Any second regular file is a re-diverged copy.
real_files="$(find "$ROOT/docker" -name grab_files.sh -type f | wc -l)"
if [ "$real_files" -ne 1 ]; then
    bad "expected exactly one real grab_files.sh under docker/, found $real_files"
fi

# 3. Every Dockerfile that installs the helper must copy it from the
#    shared 'common' build context.
for rel in distroless web web-debug web-full; do
    dockerfile="$ROOT/docker/images/$rel/Dockerfile"
    [ -f "$dockerfile" ] || { bad "missing $rel/Dockerfile"; continue; }
    grep -qF 'COPY --from=common grab_files.sh /grab_files.sh' "$dockerfile" \
        || bad "$rel/Dockerfile does not COPY grab_files.sh from the common build context"
done

# 4. Every build invocation that builds those images must supply the
#    named context (otherwise the COPY --from=common cannot resolve).
check_build() {
    local script="$1" tag="$2" line
    [ -f "$script" ] || { bad "missing $script"; return; }
    line="$(grep -F -- "$tag" "$script" | head -n1)"
    if [ -z "$line" ]; then
        bad "$(basename "$script"): could not find build invocation for $tag"
        return
    fi
    printf '%s' "$line" | grep -qF -- '--build-context common=.' \
        || bad "$(basename "$script"): $tag is built without --build-context common=."
}

check_build "$ROOT/docker/build-images.sh"      '--tag="phpexperts/php:${VERSION}"'
check_build "$ROOT/docker/build-images.sh"      '--tag="phpexperts/php:${VERSION}-debug"'
check_build "$ROOT/docker/build-images.sh"      '--tag="phpexperts/web:nginx-php${VERSION}"'
check_build "$ROOT/docker/build-images.sh"      '--tag="phpexperts/web:nginx-php${VERSION}-debug"'
check_build "$ROOT/docker/build-full-images.sh" '--tag="phpexperts/php:${VERSION}-full"'
check_build "$ROOT/docker/build-full-images.sh" '--tag="phpexperts/web:nginx-php${VERSION}-full"'
check_build "$ROOT/docker/build-distroless.sh"  '--tag="phpexperts/php:${VERSION}-distroless"'

# 5. The canonical script must still abort on unresolvable dependencies
#    and tolerate empty ldd output (the behaviours the consolidation
#    inherited from the web copies).
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
    esac
    chmod +x "$dir/ldd"
}

run_case() {
    local mode="$1" want_rc="$2"
    local tmp mockbin sandbox err rc
    tmp="$(mktemp -d)"; mockbin="$tmp/bin"; sandbox="$tmp/run.sh"
    sed "s#/tmp/distroless#$tmp/distroless#g" "$CANON" > "$sandbox"
    make_fake_ldd "$mockbin" "$mode"

    err="$(PATH="$mockbin:$PATH" bash "$sandbox" /bin/true 2>&1 >/dev/null)"
    rc=$?
    if [ "$rc" -ne "$want_rc" ]; then
        bad "canonical [$mode]: expected exit $want_rc, got $rc: $err"
    fi
    if [ "$mode" = "missing" ]; then
        printf '%s' "$err" | grep -q 'Missing library dependencies' \
            || bad "canonical [missing]: did not report the missing libraries"
        printf '%s' "$err" | grep -q 'unresolvable dependencies' \
            || bad "canonical [missing]: did not abort as unresolvable"
    fi
    rm -rf "$tmp"
}

run_case empty 0
run_case missing 3

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 5e5923e single canonical grab_files.sh is shared by all variants\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 5e5923e grab_files.sh consolidation\n' "$RED" "$RESET"
    exit 1
fi
