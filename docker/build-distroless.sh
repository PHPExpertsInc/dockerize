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

set -o pipefail

PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3 8.4"
#PHP_VERSIONS="7.4 8.0 8.1 8.2 8.3 8.4"
#PHP_VERSIONS="8.0 8.1 8.2 8.3 8.4"

# Create the apt cache volume
docker volume create apt-cache

export BUILDKIT_STEP_LOG_MAX_SIZE=104857600

# Build the base linux image first.
export DOCKER_BUILDKIT=1


for VERSION in ${PHP_VERSIONS}; do
    # Check if the base image exists and get its size
    if ! docker image inspect "phpexperts/php:${VERSION}" >/dev/null 2>&1; then
        echo "Docker image phpexperts/php:${VERSION} does not exist. Skipping..."
        continue
    fi
    
    # Get image size in bytes and convert to MB
    IMAGE_SIZE_BYTES=$(docker image inspect "phpexperts/php:${VERSION}" --format='{{.Size}}')
    IMAGE_SIZE_MB=$((IMAGE_SIZE_BYTES / 1024 / 1024))
    
    if [ $IMAGE_SIZE_MB -le 200 ]; then
        echo "Docker image phpexperts/php:${VERSION} is ${IMAGE_SIZE_MB}MB (≤200MB). Skipping..."
        continue
    fi
    
    echo "Building distroless image for PHP ${VERSION} (base image size: ${IMAGE_SIZE_MB}MB)..."
    
    # Build the distroless image
    if docker build distroless --tag="phpexperts/php:${VERSION}-distroless" --build-arg VOLUME="apt-cache:/var/lib/apt" --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain; then
        echo "Successfully built distroless image for PHP ${VERSION}"

        # Retag the existing image.
        docker tag "phpexperts/php:${VERSION}" "phpexperts/php-full:${VERSION}"

        # Remove the existing image.
        docker rmi "phpexperts/php:${VERSION}"
        
        # Tag the distroless image as the main version
        docker tag "phpexperts/php:${VERSION}-distroless" "phpexperts/php:${VERSION}"
        
        # Remove the distroless tagged image
        docker rmi "phpexperts/php:${VERSION}-distroless"
        
        echo "Successfully replaced phpexperts/php:${VERSION} with distroless version"
    else
        echo "Failed to build distroless image for PHP ${VERSION}"
    fi
done
