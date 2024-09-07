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

# Test that the proper PHP version is loaded.
PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1"

# @see https://phpunit.de/supported-versions.html
declare -A PHPUNIT_PHP_VERSIONS=(
    [5.6]=5\.
    [7.0]=6\.
    [7.1]=7\.
    [7.2]=8\.
    [7.3]=9\.
    [7.4]=9\.
    [8.0]=9\.
    [8.1]=9\.
)

for VERSION in ${PHP_VERSIONS}; do
    rm -rf composer.json composer.lock vendor/

	ACTUAL_VERSION=$(PHP_VERSION=${VERSION} php --version)
	VERSION_MATCH=$(echo $ACTUAL_VERSION | grep "${VERSION}")

	if [ $? != 0 ]; then
		echo "VERSION MISMATCH!! Looking for ${VERSION}, got ${ACTUAL_VERSION}"; exit 1
	else
		echo "Version ${VERSION} matched."
	fi

    echo "Trying to install PHPUnit..."
    PHP_VERSION=${VERSION} bin/composer require phpunit/phpunit

    if [ $? != 0 ]; then
        echo "PHPUnit was not successfully installed!"; exit 2
    fi

    PHP_VERSION=${VERSION} bin/php vendor/bin/phpunit --version
    PHP_VERSION=${VERSION} bin/php vendor/bin/phpunit --version | grep "^PHPUnit ${PHPUNIT_PHP_VERSIONS[${VERSION}]}"
    if [ $? != 0 ]; then
        echo "The incorrect version of PHPUnit was installed. Something is probably wrong."; exit 3
    fi
done

# Cleanup
rm -rf composer.json composer.lock vendor/
