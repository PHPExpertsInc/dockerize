#!/bin/bash
#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2024 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################

# Extracts binaries and libraries, and their library and file dependencies
# into a new distroless root.

ldd_deps() {
    local output
    output=$(ldd "$1" 2>/dev/null)

    if printf '%s\n' "$output" | grep -q 'not found'; then
        printf 'Error: Missing library dependencies for %s:\n' "$1" >&2
        printf '%s\n' "$output" | grep 'not found' >&2
        return 1
    fi

    printf '%s\n' "$output" | awk '
        /=>/ { if ($3 ~ /^\//) print $3; next }
        $1 ~ /^\// { print $1 }
    '
}

# If no argument is provided
if [ -z "$1" ]; then
    echo "Error: Please specify the complete path to the file or executable."
    exit 1
fi

# Check if the provided argument is neither a file nor a directory
if [ ! -e "$1" ]; then
    echo "Error: The specified file or directory does not exist."
    exit 2
fi

# If the /tmp/distroless directory does not exist
if [ ! -d /tmp/distroless ]; then
    mkdir -p /tmp/distroless
    cd /tmp/distroless || exit
    mkdir -p dev etc home/user media mnt opt proc root run sys tmp usr var/cache usr/lib usr/log usr/spool usr/tmp
    mkdir -p /tmp/distroless/usr/bin /tmp/distroless/usr/lib /tmp/distroless/usr/local/bin

    chmod 0777 tmp var/cache var/log var/tmp
    chmod 0750 root

    ln -s usr/bin bin
    ln -s usr/bin sbin
    ln -s usr/lib lib
    ln -s usr/lib lib64
fi

# If the argument is a directory
if [ -d "$1" ]; then
    # Copy the directory and its contents to the destination
    cp -a --verbose --parents "$1" /tmp/distroless

    # Iterate over each .so file found in the directory
    for lib in $(find "$1" -name '*.so*' -type f); do 
        # Copy the shared libraries needed by each .so file to the destination
        if ! deps=$(ldd_deps "$lib"); then
            echo "Error: Aborting due to unresolvable dependencies for $lib." >&2
            exit 3
        fi
        [ -n "$deps" ] && cp -v $deps /tmp/distroless/usr/lib
    done

    exit 0
fi

# Otherwise, treat the argument as a file to copy
cp -v "$1" "/tmp/distroless$1"
if [ -x "$1" ]; then
    if ! deps=$(ldd_deps "$1"); then
        echo "Error: Aborting due to unresolvable dependencies for $1." >&2
        exit 3
    fi
    [ -n "$deps" ] && cp -v --force $deps /tmp/distroless/usr/lib/
fi
