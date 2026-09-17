#!/usr/bin/env bash
#####################################################################
# Commit c2fb9d4: Propagated grab_files.sh failures in the full-image
# collection loop.
#
# The -full collection loop ended with `fi || true`, which swallowed
# any grab_files.sh failure and let a broken image build succeed.
# Verify the block aborts as soon as a grab_files.sh invocation fails,
# rather than returning the status of the final iteration.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

DOCKERFILE="$ROOT/docker/images/distroless/Dockerfile"
[ -f "$DOCKERFILE" ] || { bad "missing docker/images/distroless/Dockerfile"; printf '%sFAILED%s\n' "$RED" "$RESET"; exit 1; }

# Isolate the -full collection block (the one gated on aspell/snmp).
BLOCK_RAW="$(awk '/^RUN .*\[ -e "\/usr\/lib\/aspell" \]/{f=1} f{print} f && /^[[:space:]]*fi[[:space:]]*$/{exit}' "$DOCKERFILE")"
[ -n "$BLOCK_RAW" ] || bad "could not find the -full collection block"

if printf '%s\n' "$BLOCK_RAW" | grep -Eq 'fi[[:space:]]*\|\|[[:space:]]*true'; then
    bad "the -full collection block still swallows failures with 'fi || true'"
fi
printf '%s\n' "$BLOCK_RAW" | grep -q '/grab_files.sh' \
    || bad "the -full collection block no longer calls grab_files.sh"
printf '%s\n' "$BLOCK_RAW" | grep -q '/grab_files.sh' \
    || printf '%s\n' "$BLOCK_RAW" >&2

# Flatten the Dockerfile line continuations and drop the RUN keyword so
# the block can be executed by /bin/sh, exactly as Docker would.
BLOCK="$(printf '%s\n' "$BLOCK_RAW" | tr -d '\\\n' | sed 's/^RUN //')"

tmp="$(mktemp -d)"
mockdir="$tmp/mock"; mkdir -p "$mockdir"
cat > "$mockdir/grab" <<'EOF'
#!/usr/bin/env bash
echo "grab:$1"
if [ "${FAIL_ASPELL:-0}" = "1" ] && [ "$(basename "$1")" = "aspell" ]; then
    exit 3
fi
exit 0
EOF
chmod +x "$mockdir/grab"

# Mirror the two paths that exist in the -full base: the gate
# (/usr/lib/aspell, whose grab fails) and the last list entry (/etc/ldap).
mkdir -p "$tmp/usr/lib/aspell" "$tmp/etc/ldap"

SANDBOXED="$(printf '%s\n' "$BLOCK" \
    | sed -e "s#/grab_files.sh#$mockdir/grab#g" \
          -e "s#/usr/lib/libc-client.so.2007e#$tmp/usr/lib/libc-client.so.2007e#g" \
          -e "s#/usr/lib/aspell#$tmp/usr/lib/aspell#g" \
          -e "s#/usr/share/snmp#$tmp/usr/share/snmp#g" \
          -e "s#/etc/snmp#$tmp/etc/snmp#g" \
          -e "s#/etc/ldap#$tmp/etc/ldap#g")"

# Case 1: an earlier grab_files fails, the final path exists and would
# succeed. The block must abort on the first failure.
out="$(FAIL_ASPELL=1 sh -c "$SANDBOXED" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ]; then
    bad "block exited 0 even though grab_files.sh failed on /usr/lib/aspell"
fi
printf '%s' "$out" | grep -q 'grab:.*/usr/lib/aspell' \
    || bad "block never attempted /usr/lib/aspell; test setup is wrong"
if printf '%s' "$out" | grep -q '/etc/ldap'; then
    bad "block continued past the failing grab_files.sh call (reached /etc/ldap)"
fi

# Case 2: every grab_files succeeds. The block must exit 0.
if FAIL_ASPELL=0 sh -c "$SANDBOXED" >/dev/null 2>&1; then
    :
else
    bad "block failed even though every grab_files.sh succeeded"
fi

rm -rf "$tmp"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: c2fb9d4 propagates grab_files failures\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: c2fb9d4 failure propagation\n' "$RED" "$RESET"
    exit 1
fi
