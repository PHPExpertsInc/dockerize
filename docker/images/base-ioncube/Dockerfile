# phpexperts/php:7-base-debug

ARG PHP_VERSION=7.4
FROM phpexperts/php:${PHP_VERSION}

ARG PHP_VERSION
ENV PHP_VERSION=$PHP_VERSION

RUN cd /tmp && \
    curl -LO https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
    tar xzvf ioncube_loaders_lin_x86-64.tar.gz && \
    export EXT_DIR=$(php -r 'echo ini_get("extension_dir");') && \
    printf  "[ioncube] \n \
zend_extension=${EXT_DIR}/ioncube_loader_lin_${PHP_VERSION}.so\n" > /etc/php/${PHP_VERSION}/cli/conf.d/0-ioncube.ini && \
    mv -v ioncube/ioncube_loader_lin_${PHP_VERSION}.so $EXT_DIR/ && \
    cp /etc/php/${PHP_VERSION}/cli/conf.d/0-ioncube.ini /etc/php/${PHP_VERSION}/fpm/conf.d/ && \
    rm -rf * && \
    #
    # Cleanup
    apt-get remove -y && \
    apt-get autoremove -y && \
    apt-get clean
    #rm -rf /var/lib/apt/lists/*
