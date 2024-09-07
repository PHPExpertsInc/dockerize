#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2024 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################
# phpexperts/web-debug
ARG PHP_VERSION=8.0
FROM phpexperts/php:${PHP_VERSION}-debug
ARG PHP_VERSION

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates \
        nginx \
        php${PHP_VERSION}-fpm \
        supervisor && \
    echo "${PHP_VERSION}-debug" | tee > /VERSION && \
    #
    ## Configure PHP-FPM
    sed -i "s!display_startup_errors = Off!display_startup_errors = On!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!memory_limit =.\+!memory_limit = -1!g" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s!memory_limit =.\+!memory_limit = -1!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!;error_log = php_errors.log!error_log = /proc/1/fd/2!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!max_execution_time = 30!max_execution_time = 600!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!session.gc_probability = 0!session.gc_probability = 1!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    #
    sed -i "s!;daemonize = yes!daemonize = no!g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    sed -i "s!error_log = /var/log/php${PHP_VERSION}-fpm.log!error_log = /proc/self/fd/2!g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    #
    sed -i "s!;catch_workers_output = yes!catch_workers_output = yes!g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i "s!listen = /run/php/php${PHP_VERSION}-fpm.sock!listen = 0.0.0.0:9000!g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    # Route nginx logs to syslog socket (will show in Docker logs)
    sed -i 's!/var/log/nginx/access.log!syslog:server=unix:/dev/log!g' /etc/nginx/nginx.conf && \
    sed -i 's!/var/log/nginx/error.log!syslog:server=unix:/dev/log!g' /etc/nginx/nginx.conf && \
    # (Issue #3) Fix lines being truncated in docker logs.
    echo "log_errors_max_len = 8192" >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo "log_limit = 8192" >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo "decorate_workers_output = no" >> /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    #
    ln -s /usr/sbin/php-fpm* /usr/sbin/php-fpm && \
    #
    # Cleanup
    apt-get remove -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD supervisor/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
ADD supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf

ADD entrypoint.sh /usr/local/bin/entrypoint-web.sh

WORKDIR /var/www

ENTRYPOINT ["/usr/local/bin/entrypoint-web.sh"]
