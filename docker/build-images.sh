#!/bin/bash

#PHP_VERSIONS="7.4"
PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4"

cd images

for VERSION in ${PHP_VERSIONS}; do
  MAJOR_VERSION=${VERSION%.*}
  # @TODO: Need to add support for v8.0, too.
  docker rm $(docker ps -aq)
  docker rmi --force phpexperts/php:${MAJOR_VERSION}-debug
  docker rmi --force phpexperts/php:${MAJOR_VERSION}

  docker build base       --tag="phpexperts/php:${MAJOR_VERSION}"                         --build-arg PHP_VERSION=$VERSION
  docker build base       --tag="phpexperts/php:${VERSION}"                --build-arg PHP_VERSION=$VERSION
  docker build base-debug --tag="phpexperts/php:${VERSION}-debug"          --build-arg PHP_VERSION=$VERSION
  docker build base-debug --tag="phpexperts/php:${MAJOR_VERSION}-debug"                   --build-arg PHP_VERSION=$VERSION
  docker build web        --tag="phpexperts/web:nginx-php${VERSION}"       --build-arg PHP_VERSION=$VERSION
  docker build web-debug  --tag="phpexperts/web:nginx-php${VERSION}-debug" --build-arg PHP_VERSION=$VERSION
done
