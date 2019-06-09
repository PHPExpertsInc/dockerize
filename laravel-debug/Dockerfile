# phpexperts/php:7-laravel-debug
FROM phpexperts/php:7-laravel

COPY xdebug.conf /tmp

RUN pacman -S --noconfirm xdebug && \

    # Configure XDebug
    cat /tmp/xdebug.conf >> /etc/php/conf.d/xdebug.ini && \
    rm /tmp/xdebug.conf
