#!/usr/bin/env bash
#####################################################################
# Commit d6a8e53: Rebuilt the php-ubuntu base in build-full-images.sh
# when missing.
#
# build-images.sh removes phpexperts/php-ubuntu:${VERSION}, but
# base-full/Dockerfile's FROM still needs that tag, so a later
# full-image build failed at the FROM instruction. Verify the script
# inspects the tag and rebuilds the base image on demand.
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

grep -q 'docker image inspect "phpexperts/php-ubuntu:${VERSION}"' "$SCRIPT" \
    || bad "build-full-images.sh does not inspect for the missing base tag"
grep -q 'docker build base --tag="phpexperts/php-ubuntu:${VERSION}"' "$SCRIPT" \
    || bad "build-full-images.sh does not rebuild the base image on demand"

# Extract the actual on-demand build expression and exercise it with a
# mock docker.
SNIPPET="$(sed -n '/docker image inspect "phpexperts\/php-ubuntu:${VERSION}"/,/docker build base --tag=/p' "$SCRIPT")"
if [ -z "$SNIPPET" ]; then
    bad "could not extract the on-demand base-build snippet"
else
    mockdir="$(mktemp -d)"
    log="$mockdir/calls.log"
    cat > "$mockdir/docker" <<'EOF'
#!/usr/bin/env bash
echo "docker $*" >> "${DOCKER_LOG}"
if [ "$1" = "image" ] && [ "$2" = "inspect" ]; then
    exit "${INSPECT_RC:-0}"
fi
exit 0
EOF
    chmod +x "$mockdir/docker"

    VERSION=8.3
    DOCKER_LOG="$log" INSPECT_RC=1 PATH="$mockdir:$PATH" eval "$SNIPPET" >/dev/null 2>&1
    if grep -q 'docker build base ' "$log"; then
        :
    else
        bad "the base image is not rebuilt when the tag is missing"
    fi

    : > "$log"
    DOCKER_LOG="$log" INSPECT_RC=0 PATH="$mockdir:$PATH" eval "$SNIPPET" >/dev/null 2>&1
    if grep -q 'docker build base ' "$log"; then
        bad "the base image is rebuilt even though the tag already exists"
    fi
    rm -rf "$mockdir"
fi

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: d6a8e53 rebuilds the php-ubuntu base on demand\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: d6a8e53 on-demand base rebuild\n' "$RED" "$RESET"
    exit 1
fi
