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

time for PHPV in ${SUPPORTED_PHP_VERSIONS}-debug; do
    PHP_VERSION=$PHPV composer --version
    PHP_VERSION=$PHPV composer update
    PHPUNIT_V=''
    if [ $PHPV == '7.0' ]; then
        PHPUNIT_V='6'
    if [ $PHPV == '7.1' ]; then
        PHPUNIT_V='7'
    elif [ $PHPV == '7.2' ]; then
        PHPUNIT_V='8'
    elif [ $PHPV == '7.3' ] || [ $PHPV == '7.4' ] || [ $PHPV == '8.0' ]; then
        PHPUNIT_V='9'
    else
        if [ $PHPV == "8.1" ]; then
            PHPUNIT_V='10'
        else
            PHPUNIT_V='11'
        fi
    fi

    if [ -f phpunit.v${PHPUNIT_V}.xml ]; then
        PHP_VERSION=$PHPV phpunit -c phpunit.v${PHPUNIT_V}.xml
    else
        PHP_VERSION=$PHPV phpunit
    fi

    echo "Tested: PHP v$PHPV"
    sleep 2
done

