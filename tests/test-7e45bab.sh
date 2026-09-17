#!/usr/bin/env bash
#####################################################################
# Commit 7e45bab: Stopped build-full-images.sh on Docker build
# failures.
#
# The script had no `set -e`, so a failed image build was ignored and
# the script still exited 0. Verify `set -e` is set and that the
# pre-build `docker rmi` cleanups tolerate images that do not exist
# yet (so the first run does not abort).
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

grep -qE '^set -e\b' "$SCRIPT" \
    || bad "docker/build-full-images.sh does not enable 'set -e'; build failures will be swallowed"

mapfile -t RMI_LINES < <(grep '^[[:space:]]*docker rmi --force' "$SCRIPT")
[ "${#RMI_LINES[@]}" -gt 0 ] || bad "no 'docker rmi --force' cleanup lines found"

for line in "${RMI_LINES[@]}"; do
    case "$line" in
        *"|| true"*) : ;;
        *) bad "rmi line is not tolerant of a missing image: ${line#"${line%%[![:space:]]*}"}" ;;
    esac
done

# Behaviourally prove the cleanups survive a failing `docker rmi` under
# `set -e`, which is exactly what happens on a first build.
rmi_snippet="$(printf '%s\n' "${RMI_LINES[@]}")"
mockdir="$(mktemp -d)"
cat > "$mockdir/docker" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
chmod +x "$mockdir/docker"

VERSION=8.3
if ( set -e; PATH="$mockdir:$PATH" eval "$rmi_snippet" ) >/dev/null 2>&1; then
    :
else
    bad "cleanup lines abort under 'set -e' when the images are absent"
fi
rm -rf "$mockdir"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: 7e45bab build-full-images.sh stops on build failures\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: 7e45bab build-full-images.sh failure handling\n' "$RED" "$RESET"
    exit 1
fi
