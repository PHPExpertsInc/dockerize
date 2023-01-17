#!/usr/bin/env bash

if [ -z "$1" ]; then
    /usr/bin/php
else
    if [[ "$1" == "php" ]] || [[ "$1" == "composer" ]] || [[ "$1" == "sh" ]] || [[ "$1" == "bash" ]]; then
        "$@"
    else
        /usr/bin/php "$@"
    fi
fi
