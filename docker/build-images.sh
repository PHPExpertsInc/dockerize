#!/bin/bash

PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1"
#PHP_VERSIONS="7.4 8.0 8.1"
#PHP_VERSIONS="8.1"
cd images

# Build the base linux image first.
docker rmi phpexperts/linux:latest
docker build linux --tag="phpexperts/linux:latest"

for VERSION in ${PHP_VERSIONS}; do
  MAJOR_VERSION=${VERSION%.*}

  docker rm $(docker ps -aq)
  docker rmi --force phpexperts/php:latest 2> /dev/null
  docker rmi --force phpexperts/php:${MAJOR_VERSION}-debug 2> /dev/null
  docker rmi --force phpexperts/php:${MAJOR_VERSION} 2> /dev/null

  docker rmi --force phpexperts/web:nginx-php${VERSION}-debug 2> /dev/null
  docker rmi --force phpexperts/web:nginx-php${VERSION}-debug 2> /dev/null

  docker build base       --tag="phpexperts/php:latest"                 --build-arg PHP_VERSION=$VERSION
  docker build base       --tag="phpexperts/php:${MAJOR_VERSION}"       --build-arg PHP_VERSION=$VERSION
  docker build base       --tag="phpexperts/php:${VERSION}"             --build-arg PHP_VERSION=$VERSION
  docker build base-debug --tag="phpexperts/php:latest-debug"           --build-arg PHP_VERSION=$VERSION
  docker build base-debug --tag="phpexperts/php:${VERSION}-debug"       --build-arg PHP_VERSION=$VERSION
  docker build base-debug --tag="phpexperts/php:${MAJOR_VERSION}-debug" --build-arg PHP_VERSION=$VERSION
  docker build web        --tag="phpexperts/web:nginx-php${VERSION}"       --build-arg PHP_VERSION=$VERSION
  docker build web-debug  --tag="phpexperts/web:nginx-php${VERSION}-debug" --build-arg PHP_VERSION=$VERSION

  if [ "$MAJOR_VERSION" != "8" ]; then
    docker build base-ioncube --tag="phpexperts/php:${VERSION}-ioncube"          --build-arg PHP_VERSION=$VERSION
    docker build web-ioncube --tag="phpexperts/web:nginx-php${VERSION}-ioncube"          --build-arg PHP_VERSION=$VERSION
  fi
done

#docker rmi --force phpexperts/php:8 phpexperts/php:8.1 phpexperts/web:nginx-php8.1
#docker build base-php8 --tag="phpexperts/php:8.1"
#
#docker build web-php8 --tag="phpexperts/web:nginx-php8.1"
