# phpexperts/php:7
FROM phpexperts/linux:latest

ARG PHP_VERSION=7.4

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-gmp \
        php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-memcached \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-ssh2 \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip && \
    # Install ext-sodium if < PHP 7.2.
    if [ "${PHP_VERSION}" == "7.0" ] && [ "${PHP_VERSION}" == "7.1" ]; then \
        apt-get install -y --no-install-recommends \
            php${PHP_VERSION}-sodium; \
    fi && \
    #
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    #rm -rf /var/lib/apt/lists/* && \
    #rm -rf /var/cache/apt/* && \
    #
    # Fix "Unable to create the PID file (/run/php/php5.6-fpm.pid).: No such file or directory (2)"
    mkdir -p /run/php
    #
    ## Configure PHP
RUN sed -i "s!memory_limit =.\+!memory_limit = -1!g" /etc/php/${PHP_VERSION}/cli/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && composer --version

VOLUME ["/workdir"]
WORKDIR /workdir

EXPOSE 9000

COPY entrypoint.sh /usr/local/bin/entrypoint-php.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-php.sh"]
