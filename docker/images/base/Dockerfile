# phpexperts/php:7
FROM ubuntu:focal

ARG PHP_VERSION=7.4

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    # Configure ondrej PPA
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get upgrade -y && \
    #
    # Install PHP & curl (for composer)
    apt-get install -y --no-install-recommends \
        curl git ssh \
        php${PHP_VERSION}-cli \
        vim inetutils-ping unzip net-tools \
        php${PHP_VERSION}-fpm && \
    apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-dom \
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
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/* && \
    #
    # Fix "Unable to create the PID file (/run/php/php5.6-fpm.pid).: No such file or directory (2)"
    mkdir -p /run/php && \
    #
    ## Configure PHP-FPM
    sed -i "s!display_startup_errors = Off!display_startup_errors = On!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!;error_log = php_errors.log!error_log = /proc/self/fd/2!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!max_execution_time = 30!max_execution_time = 600!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!session.gc_probability = 0!session.gc_probability = 1!g" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    #
    sed -i "s!;daemonize = yes!daemonize = no!g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    sed -i "s!error_log = /var/log/php${PHP_VERSION}-fpm.log!error_log = /proc/self/fd/2!g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    #
    sed -i "s!;catch_workers_output = yes!catch_workers_output = yes!g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i "s!listen = /run/php/php${PHP_VERSION}-fpm.sock!listen = 0.0.0.0:9000!g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

VOLUME ["/workdir"]
WORKDIR /workdir

EXPOSE 9000

COPY entrypoint.sh /usr/local/bin/entrypoint-php.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-php.sh"]
