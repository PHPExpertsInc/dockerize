# phpexperts/php:7-base-debug
FROM phpexperts/php:latest

ARG PHP_VERSION=7.4

COPY xdebug.conf /tmp

RUN apt-get install -y php${PHP_VERSION}-xdebug && \
    #
    # Configure XDebug
    cat /tmp/xdebug.conf >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    rm /tmp/xdebug.conf && \
    #
    # Cleanup
    apt-get remove -y && \
    apt-get autoremove -y && \
    apt-get clean
    #rm -rf /var/lib/apt/lists/*
