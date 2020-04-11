#!/bin/bash

#PHP_VERSIONS="7.4"
PHP_VERSIONS="7.0 7.1 7.2 7.3 7.4"

for VERSION in ${PHP_VERSIONS}; do
  # @TODO: Need to add support for v8.0, too.
  docker rmi --force phpexperts/php:7-base-debug
  docker rmi --force phpexperts/php:7

  time docker build base          --tag="phpexperts/php:7"                         --build-arg PHP_VERSION=$VERSION
       docker build base          --tag="phpexperts/php:${VERSION}"                --build-arg PHP_VERSION=$VERSION
  time docker build base-debug --tag="phpexperts/php:${VERSION}-debug"             --build-arg PHP_VERSION=$VERSION
       docker build base-debug --tag="phpexperts/php:7-debug"                      --build-arg PHP_VERSION=$VERSION
  time docker build web           --tag="phpexperts/web:nginx-php${VERSION}"       --build-arg PHP_VERSION=$VERSION
  time docker build web-debug     --tag="phpexperts/web:nginx-php${VERSION}-debug" --build-arg PHP_VERSION=$VERSION

  echo "Continue? "
  read
done
