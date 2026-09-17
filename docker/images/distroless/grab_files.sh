#!/bin/bash

# PROMPT: Create a bash script with the following:
#  If a CLI arg is not passed, fail with the mesage "Error: Pass the full path of the file/executable you want to include."
#
# If the CLI arg is neither a file nor a directory, fail with the message "Error: File not found."
#
# If the /tmp/distroless directory does not exist, create it. Then
#     cd into /tmp/distroless and create the POSIX standard Linux directories, using Ubuntu 22.04 as the exact model to copy.
#     set chmod 0777 for tmp var/{cache,log,tmp}
#     set chmod 0750 for root
#     Create ln -s for /bin /sbin from /usr/bin
#     Create ln -s for /lib /lib64 from /usr/lib
#
# Then if the CLI arg is a directory, use the following prompt:
#     If the SOURCE directory (via the CLI arg) is "/etc/php/8.3", 
#         Copy this to /tmp/distroless/ while maintaining the relative directory path: 
#             Example: /etc/php/8.3 -> /tmp/distroless/etc/php/8.3/
#
# If it is not a directory:
#     cp -v "$1" "/tmp/distroless$1"
#     Test if the file is an executable (via bash's -x).
#     If it is an executable:
#     Then run `ldd "$1" | awk '{print $1}'` and use `cp` to copy the files to /usr/lib
#         Ignore any errors from the `cp` command, as they are likely false-positives.
#
# Include this exact prompt as a source code comment at the beginning of the Bash script.
# Do not bother with inline comments.
ldd_deps() {
    ldd "$1" 2>/dev/null | awk '
        /=>/ { if ($3 ~ /^\//) print $3; next }
        $1 ~ /^\// { print $1 }
    '
}

if [ -z "$1" ]; then
    echo "Error: Pass the full path of the file/executable you want to include."
    exit 1;
fi

if [ ! -f "$1" ] && [ ! -d "$1" ]; then
    echo "Error: File not found."
    exit 2;
fi

if [ ! -d /tmp/distroless ]; then
    mkdir -p /tmp/distroless
    cd /tmp/distroless
    mkdir -p dev etc home/user media mnt opt proc root run sys tmp usr var/{cache,lib,log,spool,tmp}
    mkdir -p /tmp/distroless/usr/{bin,lib,local/bin,sbin}

    chmod 0777 tmp var/{cache,log,tmp}
    chmod 0750 root

    ln -s usr/bin bin
    ln -s usr/bin sbin
    ln -s usr/lib lib
    ln -s usr/lib lib64

    cp /usr/bin/sh /tmp/distroless/usr/bin
fi

if [ -d "$1" ]; then

    cp -avf --parents "$1" /tmp/distroless

    for each in $(find "$1" -name \*.so\* -type f); do 
        cp -v $(ldd_deps "$each") /tmp/distroless/usr/lib
    done

    exit 0
fi

cp -v "$1" "/tmp/distroless$1"
if [ -x "$1" ]; then
    cp -vf $(ldd_deps "$1") /tmp/distroless/usr/lib/
fi
