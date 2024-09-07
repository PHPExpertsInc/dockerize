#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2024 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################
# phpexperts/php:7-base-debug

ARG PHP_VERSION=8.0
FROM phpexperts/php:${PHP_VERSION}

ARG PHP_VERSION
ENV PHP_VERSION=$PHP_VERSION

COPY .build-assets/ioncube_loaders_lin_x86-64.tar.gz /tmp

RUN cd /tmp && \
    tar xzvf ioncube_loaders_lin_x86-64.tar.gz && \
    export EXT_DIR=$(php -r 'echo ini_get("extension_dir");') && \
    printf  "[ioncube] \n \
zend_extension=${EXT_DIR}/ioncube_loader_lin_${PHP_VERSION}.so\n" > /etc/php/${PHP_VERSION}/cli/conf.d/0-ioncube.ini && \
    mv -v ioncube/ioncube_loader_lin_${PHP_VERSION}.so $EXT_DIR/ && \
    rm -rf * && \
    #
    # Cleanup
    apt-get remove -y && \
    apt-get autoremove -y && \
    apt-get clean
    #rm -rf /var/lib/apt/lists/*
