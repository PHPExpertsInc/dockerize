# phpexperts/php:7-base-debug
ARG PHP_VERSION=8.0
FROM phpexperts/php:$PHP_VERSION
ARG PHP_VERSION

ARG PHP_VERSION=8.0

COPY xdebug.conf /tmp

RUN apt-get -y update && apt-get install -y php${PHP_VERSION}-xdebug && \
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
