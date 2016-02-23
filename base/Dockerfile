# chekote/php:7
FROM chekote/ubuntu:yakkety

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y php7.0-cli && \
    apt-get install -y php7.0-fpm && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \

    # Configure PHP-FPM
    sed -i 's!display_startup_errors = Off!display_startup_errors = On!g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's!;error_log = php_errors.log!error_log = /proc/self/fd/2!g' /etc/php/7.0/fpm/php.ini && \

    sed -i 's!;daemonize = yes!daemonize = no!g' /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i 's!error_log = /var/log/php7.0-fpm.log!error_log = /proc/self/fd/2!g' /etc/php/7.0/fpm/php-fpm.conf && \

    sed -i 's!;catch_workers_output = yes!catch_workers_output = yes!g' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i 's!listen = /run/php/php7.0-fpm.sock!listen = 0.0.0.0:9000!g' /etc/php/7.0/fpm/pool.d/www.conf

VOLUME ["/data"]
WORKDIR /data

EXPOSE 9000
ENTRYPOINT ["/bin/bash", "-c"]
