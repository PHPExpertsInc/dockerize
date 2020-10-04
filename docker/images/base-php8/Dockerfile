# phpexperts/php:7
FROM ubuntu:focal as intermediate
#FROM phpexperts/php:8.0-temp

ARG PHP_VERSION=8.0

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    # Configure ondrej PPA
    apt-get install -y software-properties-common && \
    apt-get upgrade -y && \
    #
    # Install PHP & curl (for composer)
    apt-get install -y --no-install-recommends \
        curl \
        less vim inetutils-ping unzip net-tools && \
    #
    # Compile PHP 8 manuall
    apt-get install -y --no-install-recommends gcc g++ make && \
    apt-get install -y libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev \
                       libmysqlclient-dev libpq-dev libicu-dev libfreetype6-dev \
                       libxslt-dev libssl-dev libldb-dev libedit-dev libsodium-dev \
                       zlibc zlib1g zlib1g-dev libsqlite3-dev libgmp-dev libzip-dev \
                       libonig-dev && \
    #
    curl https://downloads.php.net/~carusogabriel/php-8.0.0rc1.tar.xz -o php.xz && \
    tar xvf php.xz && \
    cd php-8.0.0rc1 && \
    # Build CLI
    ./configure --enable-mbstring --with-pdo-mysql --with-pdo-pgsql --enable-mysqlnd \
                --enable-gd --with-gmp --enable-bcmath --with-curl --with-zip --with-openssl \
                --enable-sockets --with-libedit --with-sodium --enable-exif --enable-intl \
                --with-mysqli --with-xsl --with-zlib --prefix=/workdir/install/usr \
                --with-config-file-path=/etc/php/8.0/cli  --with-config-file-scan-dir=/etc/php/8.0/cli/conf.d && \
    make -j8 && \
    make install && \
    # Build FPM
    ./configure --enable-mbstring --with-pdo-mysql --with-pdo-pgsql --enable-mysqlnd \
                --enable-gd --with-gmp --enable-bcmath --with-curl --with-zip --with-openssl \
                --enable-sockets --with-libedit --with-sodium --enable-exif --enable-intl \
                --with-mysqli --with-xsl --with-zlib \
                --enable-fpm --with-fpm-user=www-data --enable-pcntl --prefix=/workdir/install/usr \
                --with-config-file-path=/etc/php/8.0/fpm  --with-config-file-scan-dir=/etc/php/8.0/fpm/conf.d && \
    make -j8 && \
    make install && \
    #
    # Fix "Unable to create the PID file (/run/php/php5.6-fpm.pid).: No such file or directory (2)"
    mkdir -p /run/php && \
    mkdir -p /workdir/install/etc/php/${PHP_VERSION}/cli/conf.d && \
    mkdir -p /workdir/install/etc/php/${PHP_VERSION}/fpm/conf.d && \
    mkdir -p /workdir/install/etc/php/${PHP_VERSION}/fpm/pool.d && \
    cd /php-8.0.0rc1 && \
    cp -v php.ini-development /workdir/install/etc/php/${PHP_VERSION}/cli/php.ini && \
    cp -v php.ini-development /workdir/install/etc/php/${PHP_VERSION}/fpm/php.ini && \
    cp -v ./sapi/fpm/php-fpm.conf /workdir/install/etc/php/${PHP_VERSION}/fpm/ && \
    cp -v ./sapi/fpm/www.conf     /workdir/install/etc/php/${PHP_VERSION}/fpm/pool.d && \
    #
    ## Configure PHP-FPM
    sed -i "s!display_startup_errors = Off!display_startup_errors = On!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!;error_log = php_errors.log!error_log = /proc/self/fd/2!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!max_execution_time = 30!max_execution_time = 600!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s!session.gc_probability = 0!session.gc_probability = 1!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/php.ini && \
    #
    sed -i "s!;daemonize = yes!daemonize = no!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    sed -i "s!error_log = /var/log/php${PHP_VERSION}-fpm.log!error_log = /proc/self/fd/2!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    #
    sed -i "s!;catch_workers_output = yes!catch_workers_output = yes!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i "s!listen = /run/php/php${PHP_VERSION}-fpm.sock!listen = 0.0.0.0:9000!g" /workdir/install/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \

    cd /workdir/install && \
    tar czvf /workdir/php-${PHP_VERSION}-ubuntu.tar.gz *

WORKDIR /workdir

FROM ubuntu:focal

ARG PHP_VERSION=8.0

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

COPY --from=intermediate /workdir/php-8.0-ubuntu.tar.gz /php-8.0-ubuntu.tar.gz

RUN apt-get update && \
    # Configure ondrej PPA
    apt-get install -y software-properties-common && \
    apt-get upgrade -y && \
    #
    # Install PHP & curl (for composer)
    apt-get install -y --no-install-recommends \
        curl \
        less vim inetutils-ping unzip net-tools && \
    # Install PHP extension dependencies
    apt-get install -y libpq5 libpng16-16 libonig5 libzip5 libxslt-dev zlibc zlib1g libsodium-dev libedit-dev && \
    #
    # Cleanup
    apt-get remove -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    tar xvf php-8.0-ubuntu.tar.gz && \
    rm -v php-8.0-ubuntu.tar.gz

VOLUME ["/workdir"]
WORKDIR /workdir

COPY entrypoint.sh /usr/local/bin/entrypoint-php.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-php.sh"]
