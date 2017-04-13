#!/usr/bin/env bash

if [ "$PHP_FPM_USER_ID" != "" ]; then
    usermod -u $PHP_FPM_USER_ID www-data
fi

/usr/local/bin/entrypoint.sh "$@"
