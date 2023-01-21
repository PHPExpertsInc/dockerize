# phpexperts/web-debug
ARG PHP_VERSION=7.4
FROM phpexperts/php:${PHP_VERSION}-debug
ARG PHP_VERSION

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates \
        nginx \
        supervisor && \

    # Route nginx logs to syslog socket (will show in Docker logs)
    sed -i 's!/var/log/nginx/access.log!syslog:server=unix:/dev/log!g' /etc/nginx/nginx.conf && \
    sed -i 's!/var/log/nginx/error.log!syslog:server=unix:/dev/log!g' /etc/nginx/nginx.conf && \
    ln -s /usr/sbin/php-fpm* /usr/sbin/php-fpm && \

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
