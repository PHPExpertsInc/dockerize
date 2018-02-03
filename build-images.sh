#!/bin/bash

docker build base          --tag="phpexperts/php:7"
docker build laravel       --tag="phpexperts/php:7-laravel"
docker build laravel-debug --tag="phpexperts/php:7-laravel-debug"
docker build web           --tag="phpexperts/web:nginx-php7.2"
docker build web-debug     --tag="phpexperts/web:nginx-php7.2-debug"
