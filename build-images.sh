#!/bin/bash

PHP_VERSIONS="7.1 7.2 7.3 7.4"

for VERSION in ${PHP_VERSIONS}; do
  # @TODO: Need to add support for v8.0, too.
  docker rmi --force phpexperts/php:7-laravel-debug
  docker rmi --force phpexperts/php:7-laravel
  docker rmi --force phpexperts/php:7

  time docker build base          --tag="phpexperts/php:${VERSION}"                --build-arg PHP_VERSION=$VERSION
       docker build base          --tag="phpexperts/php:7"                         --build-arg PHP_VERSION=$VERSION
  time docker build laravel       --tag="phpexperts/php:${VERSION}-laravel"        --build-arg PHP_VERSION=$VERSION
       docker build laravel       --tag="phpexperts/php:7-laravel"                 --build-arg PHP_VERSION=$VERSION
  time docker build laravel-debug --tag="phpexperts/php:${VERSION}-laravel-debug"  --build-arg PHP_VERSION=$VERSION
       docker build laravel-debug --tag="phpexperts/php:7-laravel-debug"           --build-arg PHP_VERSION=$VERSION
  time docker build web           --tag="phpexperts/web:nginx-php${VERSION}"       --build-arg PHP_VERSION=$VERSION
  time docker build web-debug     --tag="phpexperts/web:nginx-php${VERSION}-debug" --build-arg PHP_VERSION=$VERSION
done
