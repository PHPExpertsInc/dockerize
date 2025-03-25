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

ORIG_PHP_VERSION=$PHP_VERSION
if [ -f "${ROOT}/.env" ]; then
    source "${ROOT}/.env"
    if [ ! -z "$ORIG_PHP_VERSION" ]; then
        PHP_VERSION="$ORIG_PHP_VERSION"
    fi
fi

# 1) Default the PHP version to 8.4 if not provided.
if [ -z "$PHP_VERSION" ]; then
    export PHP_VERSION=8.4
fi

# 2) The extension name must be passed in.
EXTENSION="$1"
if [ -z "$EXTENSION" ]; then
    echo "Usage: $0 <extension>"
    echo "Example: $0 uuid"
    exit 1
fi


DEST_PATH=./base-full/exts/ext-$EXTENSION.$PHP_VERSION.tar.xz

# 3) Remove the previous build so we don't accdientally ship old
#    extensions just because a build failed and we didn't realize...
rm -f "$DEST_PATH"

# 4) Run the container and "cat" out the built tarball to the host.
#    Save as: build-assets.<extension>.<PHP_VERSION>.tar.xz
IMAGE="phpexperts/ext-builder:$PHP_VERSION"
docker run --rm -v ./base-full/exts:/exts "$IMAGE" uuid "$DEST_PATH"

echo ""
echo ""
echo "Done! The file is at $DEST_PATH"
ls -lh "$DEST_PATH"
md5sum "$DEST_PATH"
