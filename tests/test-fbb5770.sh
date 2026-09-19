#!/usr/bin/env bash
#####################################################################
# Commit fbb5770: Project the CLI SAPI's extensions onto PHP-FPM.
#
# The distroless CLI base images install their extensions while no FPM
# SAPI exists, so phpenmod only creates cli/conf.d links. The web images
# layer php-fpm on top, and PHP-FPM silently ran without curl, mbstring,
# mysql, ... even though the same image's CLI reported them. Verify the
# shipped stages run the projection step and that it mirrors cli/conf.d
# into fpm/conf.d without clobbering existing links.
#####################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'
FAILED=0
bad() { printf '  [error] %s\n' "$1" >&2; FAILED=1; }

SCRIPT="$ROOT/docker/images/link-fpm-extensions.sh"
[ -f "$SCRIPT" ] || bad "missing $SCRIPT"

# Print only the lines belonging to the final (shipped) stage.
final_stage() {
    awk '/^FROM /{buf=""; seen=1} seen{buf=buf $0 "\n"} END{printf "%s", buf}' "$1"
}

for label in web web-debug web-full web-ioncube; do
    file="$ROOT/docker/images/$label/Dockerfile"
    [ -f "$file" ] || { bad "$label: missing $file"; continue; }
    final="$(final_stage "$file")"
    printf '%s' "$final" | grep -q 'link-fpm-extensions.sh' \
        || bad "$label: final stage does not project CLI extensions onto FPM"
    printf '%s' "$final" | grep -q 'PHP_VERSION="${PHP_VERSION}" bash /link-fpm-extensions.sh' \
        || bad "$label: final stage does not run link-fpm-extensions.sh with PHP_VERSION"
done

# Functional check of the projection against a fixture.
run_projection() {
    PHP_CONF_DIR="$1" PHP_VERSION=8.4 bash "$SCRIPT" 2>&1
}

tmp="$(mktemp -d)"
conf="$tmp/php"
mkdir -p "$conf/8.4/mods-available" "$conf/8.4/cli/conf.d" "$conf/8.4/fpm/conf.d"
for m in curl mbstring apcu; do : > "$conf/8.4/mods-available/$m.ini"; done
ln -s "$conf/8.4/mods-available/apcu.ini"     "$conf/8.4/cli/conf.d/10-apcu.ini"
ln -s "$conf/8.4/mods-available/curl.ini"     "$conf/8.4/cli/conf.d/20-curl.ini"
ln -s "$conf/8.4/mods-available/mbstring.ini" "$conf/8.4/cli/conf.d/20-mbstring.ini"
# A pre-existing FPM link must not be clobbered.
ln -s /pre-existing/target.ini "$conf/8.4/fpm/conf.d/10-apcu.ini"

out="$(run_projection "$conf")"; rc=$?
[ "$rc" -eq 0 ] || bad "projection exited $rc: $out"

for m in curl mbstring; do
    dest="$conf/8.4/fpm/conf.d/20-${m}.ini"
    if [ ! -L "$dest" ]; then
        bad "projection did not enable $m for the FPM SAPI"
        continue
    fi
    target="$(readlink "$dest")"
    [ "$target" = "$conf/8.4/cli/conf.d/20-${m}.ini" ] \
        || bad "FPM $m link points at $target"
done

[ "$(readlink "$conf/8.4/fpm/conf.d/10-apcu.ini")" = "/pre-existing/target.ini" ] \
    || bad "projection clobbered a pre-existing FPM link"

# Running again must be a no-op.
out="$(run_projection "$conf")"; rc=$?
[ "$rc" -eq 0 ] || bad "second projection exited $rc: $out"
printf '%s' "$out" | grep -q 'Enabled 0 FPM extension' \
    || bad "projection is not idempotent: $out"

# A missing SAPI conf.d must fail loudly rather than silently doing nothing.
if PHP_CONF_DIR="$tmp/empty" PHP_VERSION=8.4 bash "$SCRIPT" >/dev/null 2>&1; then
    bad "projection succeeded without a cli/conf.d directory"
fi

rm -rf "$tmp"

if [ "$FAILED" -eq 0 ]; then
    printf '%sPASSED%s: fbb5770 web FPM extensions mirror the CLI SAPI\n' "$GREEN" "$RESET"
else
    printf '%sFAILED%s: fbb5770 web FPM extension projection\n' "$RED" "$RESET"
    exit 1
fi
