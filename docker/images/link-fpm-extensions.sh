#!/usr/bin/env bash
#
# Project the CLI SAPI's enabled PHP extensions onto the PHP-FPM SAPI.
#
# The distroless CLI base images (phpexperts/php:${PHP_VERSION} and its -full
# and -debug variants) install their extension packages while no FPM SAPI
# exists. Ubuntu's phpenmod only creates a conf.d symlink for a SAPI whose
# conf.d directory already exists, so those bases carry every extension under
# cli/conf.d but none under fpm/conf.d. The web images layer php-fpm on top of
# such a base, which is why `php -m` lists curl, mbstring, mysql, ... while
# php-fpm silently runs without them. Mirror the CLI links into fpm/conf.d so
# the FPM SAPI sees the same module set.
#
# PHP_CONF_DIR can be overridden for testing.
set -euo pipefail

PHP_CONF_DIR="${PHP_CONF_DIR:-/etc/php}"
VERSION="${PHP_VERSION:?PHP_VERSION is not set}"
CLI_CONF_D="${PHP_CONF_DIR}/${VERSION}/cli/conf.d"
FPM_CONF_D="${PHP_CONF_DIR}/${VERSION}/fpm/conf.d"

if [ ! -d "$CLI_CONF_D" ]; then
    echo "Error: $CLI_CONF_D does not exist." >&2
    exit 1
fi

if [ ! -d "$FPM_CONF_D" ]; then
    echo "Error: $FPM_CONF_D does not exist." >&2
    exit 1
fi

enabled=0
for ini in "$CLI_CONF_D"/*.ini; do
    # Guard against an unmatched glob.
    if [ ! -e "$ini" ] && [ ! -L "$ini" ]; then
        continue
    fi

    name="${ini##*/}"
    dest="${FPM_CONF_D}/${name}"

    # Never clobber a link that PHP-FPM already has.
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        continue
    fi

    # `ln` is not present in the distroless image, but `cp -s` is.
    if ! cp -s "$ini" "$dest"; then
        echo "Error: Failed to enable $name for the FPM SAPI." >&2
        exit 1
    fi

    enabled=$((enabled + 1))
done

echo "Enabled ${enabled} FPM extension(s) from the CLI SAPI."
