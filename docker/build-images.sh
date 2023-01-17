#!/bin/bash

PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1"
#PHP_VERSIONS="7.0 7.1 7.2 7.3 7.4 8.0 8.1"
#PHP_VERSIONS="7.4 8.0 8.1"
#PHP_VERSIONS="8.1"
cd images

export BUILDKIT_STEP_LOG_MAX_SIZE=104857600

# Build the base linux image first.
export DOCKER_BUILDKIT=1
docker rmi --force phpexperts/linux:latest
docker build linux --tag="phpexperts/linux:latest" --no-cache --progress=plain
docker tag phpexperts/linux:latest phpexperts/linux:$(date '+%Y-%m-%d')

for VERSION in ${PHP_VERSIONS}; do
  MAJOR_VERSION=${VERSION%.*}

  docker rm $(docker ps -aq)
  docker rmi --force phpexperts/php:latest 2> /dev/null
  docker rmi --force phpexperts/php:latest-debug 2> /dev/null
  docker rmi --force phpexperts/php:${MAJOR_VERSION}-debug 2> /dev/null
  docker rmi --force phpexperts/php:${MAJOR_VERSION} 2> /dev/null
  docker rmi --force phpexperts/php:${VERSION} 2> /dev/null
  docker rmi --force phpexperts/php:${VERSION}-debug 2> /dev/null

  docker rmi --force phpexperts/web:nginx-php${VERSION}-debug 2> /dev/null
  docker rmi --force phpexperts/web:nginx-php${VERSION}-debug 2> /dev/null

  docker build base       --tag="phpexperts/php:latest"                    --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  docker tag phpexperts/php:latest "phpexperts/php:${MAJOR_VERSION}"
  docker tag phpexperts/php:latest "phpexperts/php:${VERSION}"

  docker build full       --tag="phpexperts/php:${VERSION}-full"           --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain

  docker build base-debug --tag="phpexperts/php:latest-debug"              --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  docker tag phpexperts/php:latest "phpexperts/php:${MAJOR_VERSION}-debug"
  docker tag phpexperts/php:latest "phpexperts/php:${VERSION}-debug"

  docker build web        --tag="phpexperts/web:nginx-php${VERSION}"       --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  docker build web-debug  --tag="phpexperts/web:nginx-php${VERSION}-debug" --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain

  if [ "$MAJOR_VERSION" != "8" ]; then
    docker build base-ioncube --tag="phpexperts/php:${VERSION}-ioncube"          --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
    docker build web-ioncube  --tag="phpexperts/web:nginx-php${VERSION}-ioncube" --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  fi
done

#docker rmi --force phpexperts/php:8.2 phpexperts/web:nginx-php8.2
#docker build base-php8 --tag="phpexperts/php:8.2" --no-cache --progress=plain

#docker build web-php8 --tag="phpexperts/web:nginx-php8.2" --no-cache --progress=plain
