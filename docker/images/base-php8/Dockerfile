#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2024 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################
# phpexperts/php:7
FROM phpexperts/linux:latest AS intermediate
#FROM phpexperts/php:8.0-temp

ARG PHP_VERSION=8.4

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Compile PHP 8.x manually
RUN apt-get install -y --no-install-recommends gcc g++ make file && \
    apt-get install -y libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev \
                       libmysqlclient-dev libpq-dev libicu-dev libfreetype6-dev \
                       libxslt-dev libssl-dev libldb-dev libedit-dev libsodium-dev \
                       zlib1g zlib1g-dev libsqlite3-dev libgmp-dev libzip-dev \
                       libonig-dev binutils && \
    #
    curl https://downloads.php.net/~calvinb/php-8.4.0beta5.tar.xz -o php.xz && \
    tar xvf php.xz && \
    cd php-* && \
    # Build CLI
    ./configure --enable-mbstring --with-pdo-mysql --with-pdo-pgsql --enable-mysqlnd \
                --enable-gd --with-gmp --enable-bcmath --with-curl --with-zip --with-openssl \
                --enable-sockets --disable-phpdbg --with-libedit --with-sodium --enable-exif --enable-intl \
                --with-mysqli --with-xsl --with-zlib --prefix=/workdir/install/usr \
                --with-config-file-path=/etc/php/${PHP_VERSION}/cli  --with-config-file-scan-dir=/etc/php/${PHP_VERSION}/cli/conf.d && \
    make -j8 && \
    make install && \
    # Build FPM
    ./configure --enable-mbstring --with-pdo-mysql --with-pdo-pgsql --enable-mysqlnd \
                --enable-gd --with-gmp --enable-bcmath --with-curl --with-zip --with-openssl \
                --enable-sockets --disable-phpdbg --with-libedit --with-sodium --enable-exif --enable-intl \
                --with-mysqli --with-xsl --with-zlib \
                --enable-fpm --with-fpm-user=www-data --enable-pcntl --prefix=/workdir/install/usr \
                --with-config-file-path=/etc/php/${PHP_VERSION}/fpm  --with-config-file-scan-dir=/etc/php/${PHP_VERSION}/fpm/conf.d && \
    make -j8 && \
    make install && \
    #
    # Fix "Unable to create the PID file (/run/php/php5.6-fpm.pid).: No such file or directory (2)"
    mkdir -p /run/php && \
    mkdir -p /workdir/install/etc/php/${PHP_VERSION}/cli/conf.d && \
    mkdir -p /workdir/install/etc/php/${PHP_VERSION}/fpm/conf.d && \
    mkdir -p /workdir/install/etc/php/${PHP_VERSION}/fpm/pool.d && \
    #
    cp -v php.ini-development /workdir/install/etc/php/${PHP_VERSION}/cli/php.ini && \
    cp -v php.ini-development /workdir/install/etc/php/${PHP_VERSION}/fpm/php.ini && \
    cp -v ./sapi/fpm/php-fpm.conf /workdir/install/etc/php/${PHP_VERSION}/fpm/ && \
    cp -v ./sapi/fpm/www.conf     /workdir/install/etc/php/${PHP_VERSION}/fpm/pool.d

## Fix the extension_dir path (screwed up from --prefix=/workdir/install/usr):
RUN echo extension_dir=$(/workdir/install/usr/bin/php --info | grep ^extension_dir | awk '{print $3}' | sed 's#/workdir/install##') >> /workdir/install/etc/php/${PHP_VERSION}/cli/php.ini && \
    echo extension_dir=$(/workdir/install/usr/bin/php --info | grep ^extension_dir | awk '{print $3}' | sed 's#/workdir/install##') >> /workdir/install/etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i 's#/workdir/install##' /workdir/install/usr/bin/phpize && \
    #
    ## Remove the worthless php-cgi and save 64 MB.
    rm /workdir/install/usr/bin/php-cgi && \
    ## Strip the PHP binaries to dramatically reduce the image size (583 MB to 156 MB).
    strip -v /workdir/install/usr/bin/php /workdir/install/usr/sbin/php-fpm && \
    #
    ## Install PHP so that the build programs will work.
    cp -avf /workdir/install/* / && \
    #
    ## Install Custom PHP Extensions
    # Zend Opcache
    echo "zend_extension=opcache" > /workdir/install/etc/php/${PHP_VERSION}/cli/conf.d/opcache.ini && \
    echo "zend_extension=opcache" > /workdir/install/etc/php/${PHP_VERSION}/fpm/conf.d/opcache.ini && \
    # Redis
    apt-get install -y autoconf && \
    cd /workdir && \
    #
    curl -L https://github.com/phpredis/phpredis/archive/develop.zip -o phpredis.zip && \
    unzip phpredis.zip && \
    cd phpredis-develop && \
    phpize && \
    ./configure && \
    make -j8 && \
    make install && \
    echo "extension=redis" > /workdir/install/etc/php/${PHP_VERSION}/cli/conf.d/redis.ini && \
    echo "extension=redis" > /workdir/install/etc/php/${PHP_VERSION}/fpm/conf.d/redis.ini && \
    ## Install the new extensions, mostly for debug-on-build-failure.
    cp -avf /workdir/install/* / && \
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
    #
    cd /workdir/install && \
    tar cvf /workdir/php-${PHP_VERSION}-ubuntu.tar * && \
    echo "Finished"

WORKDIR /workdir

ENTRYPOINT ["/usr/bin/bash", "-l"]

FROM phpexperts/linux:latest

ARG PHP_VERSION=8.4

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=intermediate /workdir/php-${PHP_VERSION}-ubuntu.tar /php-${PHP_VERSION}-ubuntu.tar

RUN apt-get update && \
    # Configure ondrej PPA
    apt-get install -y software-properties-common && \
    apt-get upgrade -y && \
    #
    # Install PHP & curl (for composer)
    # Install PHP extension dependencies
    apt-get install -y libpq5 libpng16-16 libonig5 libxslt-dev zlib1g libsodium-dev libedit-dev libcurl4 libzip4 && \
    #
    # Cleanup
    apt-get remove -y && \
    apt-get autoremove -y && \
    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* && \
    cd / && \
    tar xvf php-${PHP_VERSION}-ubuntu.tar && \
    rm -v php-${PHP_VERSION}-ubuntu.tar && \
    echo "Finished..."

WORKDIR /workdir

COPY entrypoint.sh /usr/local/bin/entrypoint-php.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-php.sh"]

