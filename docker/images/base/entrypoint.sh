#!/usr/bin/env bash
#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2024 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################

if [ -z "$1" ]; then
    /usr/bin/php
else
    if [[ "$1" == "php" ]] || [[ "$1" == "composer" ]] || [[ "$1" == "sh" ]] || [[ "$1" == "bash" ]]; then
        $@
    else
        /usr/bin/php "$@"
    fi
fi
