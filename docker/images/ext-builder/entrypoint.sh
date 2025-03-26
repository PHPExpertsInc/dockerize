#!/usr/bin/env bash
#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2020-2025 PHP Experts, Inc. <sales@phpexperts.pro>  #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################
set -e

EXTENSION="$1"
if [ -z "$EXTENSION" ]; then
    echo "Usage: $0 <extensionName>"
    echo "Example: $0 gd"
    exit 1
fi

# The deps file is named "<extension>-deps.sh" in the "deps" dir.
DEPS_FILE="/workdir/deps/${EXTENSION}.deps"

# Check if the deps file exists.
if [ ! -f "$DEPS_FILE" ]; then
    echo "Error: No deps file found at '$DEPS_FILE' for extension '$EXTENSION'."
    exit 1
fi

# Source the deps file, which sets $PACKAGES
source "$DEPS_FILE"

# Ensure $PACKAGES is set by the deps file.
if [ -z "$PACKAGES" ]; then
    echo "Error: '$DEPS_FILE' did not set the PACKAGES variable."
    exit 1
fi

#PHP_VERSION=$(/usr/bin/php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')

mkdir -p /build-assets

apt-get install -y $PACKAGES

echo "Successfully installed packages for $EXTENSION: $PACKAGES"

dpkg -L $PACKAGES | while read FILEPATH; do
    # Some listed "files" may be directories or manpages. Filter if you like, for instance:
    if [ -f "$FILEPATH" ]; then
        # Ensure we replicate the directory structure
        mkdir -p "/build-assets/$(dirname "$FILEPATH")"
        cp -v "$FILEPATH" "/build-assets$FILEPATH"
    fi
done


for PHP_VERSION in /etc/php/*/; do
    PHP_VERSION=$(basename "$PHP_VERSION")
    echo "Building $EXTENSION for PHP v${PHP_VERSION}..."

    # Non-interactive installation; skip prompts.
    pecl config-set php_suffix $PHP_VERSION
    yes "" | PHP_PEAR_PHP_BIN=php${PHP_VERSION} /usr/bin/pecl install -f "$EXTENSION"

    # Figure out the likely .so name by stripping any version suffix (e.g., "uuid-1.2.1" -> "uuid")
    SO_BASENAME=$(echo "$EXTENSION" | cut -d- -f1)
    SO_FILE="$(php-config${PHP_VERSION} --extension-dir)/${SO_BASENAME}.so"

    if [ ! -f "$SO_FILE" ]; then
        echo "Error: Could not locate $SO_FILE. The extension build may have failed or the .so name is unexpected."
        exit 1
    fi

    mkdir -vp /build-assets$(dirname $SO_FILE)
    cp -v "$SO_FILE" /build-assets$SO_FILE

    EXTENSION_FILE=ext-$EXTENSION.$PHP_VERSION.tar.xz

    ## Setup the extension's configuration...
    mkdir -p /build-assets/etc/php/${PHP_VERSION}/mods-available /build-assets/etc/php/${PHP_VERSION}/cli/conf.d
    echo "extension=$SO_BASENAME" > /build-assets/etc/php/${PHP_VERSION}/mods-available/$EXTENSION.ini
    # Do NOT add /build-assets to the destination... In the container, it'll resolve just fine...
    ln -sv /etc/php/${PHP_VERSION}/mods-available/$EXTENSION.ini /build-assets/etc/php/${PHP_VERSION}/cli/conf.d/$EXTENSION.ini

    mkdir -p /exts
    tar cJvf /exts/$EXTENSION_FILE -C /build-assets/ .
    rm -rvf /build-assets/etc/php/ /build-assets/usr/lib/php/

    echo ""
    echo ""
    echo "Successfully installed '$EXTENSION' and copied $SO_FILE to ./base-full/exts/$EXTENSION_FILE"

done

