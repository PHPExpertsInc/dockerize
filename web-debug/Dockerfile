# phpexperts/web
FROM phpexperts/php:7-laravel-debug

RUN pacman -S --noconfirm \
        ca-certificates \
        nginx \
        supervisor \
        php-fpm && \

    # Route nginx logs to syslog socket (will show in Docker logs)
    sed -i 's!/var/log/nginx/access.log!syslog:server=unix:/dev/log!g' /etc/nginx/nginx.conf && \
    sed -i 's!/var/log/nginx/error.log!syslog:server=unix:/dev/log!g' /etc/nginx/nginx.conf && \

    ## Configure PHP-FPM
    cp /etc/php/php.ini /etc/php/php-cli.ini && \
    sed -i "s!display_startup_errors = Off!display_startup_errors = On!g" /etc/php/php.ini && \
    sed -i "s!;error_log = php_errors.log!error_log = /proc/self/fd/2!g" /etc/php/php.ini && \
    sed -i "s!max_execution_time = 30!max_execution_time = 600!g" /etc/php/php.ini && \
    sed -i "s!session.gc_probability = 0!session.gc_probability = 1!g" /etc/php/php.ini && \

#    sed -i "s!;daemonize = yes!daemonize = no!g" /etc/php/php-fpm.conf && \
#    sed -i "s!error_log = /var/log/php-fpm.log!error_log = /proc/self/fd/2!g" /etc/php/php-fpm.conf && \
#
#    sed -i "s!;catch_workers_output = yes!catch_workers_output = yes!g" /etc/php/php-fpm.d/www.conf && \
#    sed -i "s!listen = /run/php/php-fpm.sock!listen = 0.0.0.0:9000!g" /etc/php/${PH:P_VERSION}/fpm/pool.d/www.conf && \

    mkdir /etc/nginx/custom

ADD supervisor/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
ADD supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD nginx.conf /etc/nginx/sites-available/default

ADD entrypoint.sh /usr/local/bin/entrypoint-web.sh

WORKDIR /var/www

ENTRYPOINT ["/usr/local/bin/entrypoint-web.sh"]
