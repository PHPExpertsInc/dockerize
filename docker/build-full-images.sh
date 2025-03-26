#!/bin/bash
#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2020-2025 PHP Experts, Inc. <sales@phpexperts.pro>  #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################

#PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3 8.4"
#PHP_VERSIONS="7.4 8.0 8.1 8.2 8.3 8.4"
PHP_VERSIONS="8.0 8.1 8.2 8.3 8.4"
cd images

# Create the apt cache volume
docker volume create apt-cache

export BUILDKIT_STEP_LOG_MAX_SIZE=104857600

# Build the base linux image first.
export DOCKER_BUILDKIT=1

docker build ext-builder --tag="phpexperts/ext-builder:latest" --build-arg VOLUME="apt-cache:/var/lib/apt" --progress=plain

# @TODO: Investigate whether it's really best to download all of these extensions in ./build.images.
if [ ! -f ./base-full/.build-assets/uuid-1.2.1.tar.gz ]; then
    curl -fsSLO https://pecl.php.net/get/uuid-1.2.1.tgz
    mkdir -p ./base-full/.build-assets
    mv uuid-1.2.1.tgz ./base-full/.build-assets/uuid-1.2.1.tar.gz
fi

# Install extra extensions. These are built for PHP v8.*.
for dep in ext-builder/deps/*.deps; do
    EXTENSION=$(basename $dep .deps)
    echo "===== BUILDING $EXTENSION for PHP ${PHP_VERSIONS} ====="
    sleep 2
    ./ext-builder.sh $EXTENSION
done


for VERSION in ${PHP_VERSIONS}; do
    docker rmi --force phpexperts/php:${VERSION}-full
    docker build base-full  --tag="phpexperts/php:${VERSION}-full"           --build-arg VOLUME="apt-cache:/var/lib/apt" --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
done

docker volume rm apt-cache

# PHP-Next builds...
#docker rmi --force phpexperts/php:8.2 phpexperts/web:nginx-php8.2
#docker build base-php8 --tag="phpexperts/php:8.2" --no-cache --progress=plain

#docker build web-php8 --tag="phpexperts/web:nginx-php8.2" --no-cache --progress=plain
