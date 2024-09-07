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

# Check if the provided argument is an executable file
if [ -x "$1" ]; then
    # Change directory to the 64-bit library path
    cd /usr/lib/x86_64-linux-gnu || exit
    # Copy the shared libraries required by the executable to the destination
    cp -v --force $(ldd "$1" | awk '{print $1}') /tmp/distroless/usr/lib/
fi

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
        cd /usr/lib/x86_64-linux-gnu || exit
        # Copy the shared libraries needed by each .so file to the destination
        cp -v $(ldd "$lib" | awk '{print $1}') /tmp/distroless/usr/lib
    done

    exit 0
fi

# Otherwise, treat the argument as a file to copy
cp -v "$1" "/tmp/distroless$1"
if [ -x "$1" ]; then
    cd /usr/lib/x86_64-linux-gnu || exit
    cp -v --force $(ldd "$1" | awk '{print $1}') /tmp/distroless/usr/lib/
fi
