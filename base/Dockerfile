# chekote/php:7
FROM chekote/ubuntu:zesty

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VERSION 7.1

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y php${PHP_VERSION}-cli && \
    apt-get install -y php${PHP_VERSION}-fpm && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \

    # Fix "php-fpm cannot create pid file"
    mkdir /run/php && \

    ## Configure PHP-FPM
    sed -i "s!display_startup_errors = Off!display_startup_errors = On!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!;error_log = php_errors.log!error_log = /proc/self/fd/2!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \

    sed -i "s!;daemonize = yes!daemonize = no!g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    sed -i "s!error_log = /var/log/php${PHP_VERSION}-fpm.log!error_log = /proc/self/fd/2!g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \

    sed -i "s!;catch_workers_output = yes!catch_workers_output = yes!g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i "s!listen = /run/php/php${PHP_VERSION}-fpm.sock!listen = 0.0.0.0:9000!g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \

    # Docker for Mac mounts volumes as user id# 1000. We need to match that to allow PHP to read/write these volumes
    usermod -u 1000 www-data

VOLUME ["/workdir"]
WORKDIR /workdir

USER www-data

EXPOSE 9000
ENTRYPOINT ["/bin/bash", "-c"]
