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

SUPPORTED_PHP_VERSIONS=$(php vendor/phpexperts/docker*/version-constraints.php)
echo "Supported PHP versions: $SUPPORTED_PHP_VERSIONS"

if [ -f .env ]; then
    source .env
fi

ORIG_PHPUNIT_V=''
if [ -z "$PHPUNIT_V" ]; then
    ORIG_PHPUNIT_V="$PHPUNIT_V"
fi

time for PHPV in ${SUPPORTED_PHP_VERSIONS}-debug; do
    PHP_VERSION=$PHPV composer --version
    PHP_VERSION=$PHPV composer update
    DISPLAY_WARNINGS="--display-warnings --display-deprecations"
    # Assign the PHPUnit version, if it's not set inside of .env or $_ENV.
    if [ "$ORIG_PHPUNIT_V" == '' ]; then
        if [ $PHPV == '7.0' ]; then
            PHPUNIT_V='6'
            DISPLAY_WARNINGS=''
        elif [ $PHPV == '7.1' ]; then
            PHPUNIT_V='7'
            DISPLAY_WARNINGS=''
        elif [ $PHPV == '7.2' ]; then
            PHPUNIT_V='8'
            DISPLAY_WARNINGS=''
        elif [ $PHPV == '7.3' ] || [ $PHPV == '7.4' ] || [ $PHPV == '8.0' ]; then
            PHPUNIT_V='9'
            DISPLAY_WARNINGS=''
        elif [ $PHPV == '8.1' ]; then
            PHPUNIT_V='10'
        elif [ $PHPV == '8.2' ]; then
            PHPUNIT_V='11'
        else
            PHPUNIT_V='12'
        fi
    fi

    if [ -f phpunit.v${PHPUNIT_V}.xml ]; then
        echo PHP_VERSION=$PHPV phpunit -c phpunit.v${PHPUNIT_V}.xml $DISPLAY_WARNINGS
        PHP_VERSION=$PHPV phpunit -c phpunit.v${PHPUNIT_V}.xml $DISPLAY_WARNINGS
    else
        PHP_VERSION=$PHPV phpunit $DISPLAY_WARNINGS
    fi

    echo "Tested: PHP v$PHPV via PHPUnit v$PHPUNIT_V"
    sleep 2
done

