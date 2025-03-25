#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2025 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################

ARG PHP_VERSION=8.1
FROM phpexperts/php:$PHP_VERSION
ARG PHP_VERSION
ENV PHP_VERSION=$PHP_VERSION

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

## Change the mirror to Turkey, because I'm in UAE right now and it's damn slow.
#RUN sed -i -e 's#http://archive.ubuntu.com/ubuntu/#https://mirror.alastyr.com/ubuntu/ubuntu-archive/#' /etc/apt/sources.list

# Download oracle packages and install OCI8
RUN apt-get update && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-pspell \
        php${PHP_VERSION}-snmp \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-xmlrpc \
        && \
    # Compile ext-uuid \
    apt-get install -y build-essential php-pear php${PHP_VERSION}-dev && \
    pecl channel-update pecl.php.net
#    echo "instantclient,/opt/oracle/instantclient" | pecl install pecl install $(cat /tmp/oci8.target) && \
#    echo "extension=uuid" >> /etc/php/${PHP_VERSION}/mods-available/uuid.ini && \
#    ln -s /etc/php/${PHP_VERSION}/mods-available/uuid.ini /etc/php/${PHP_VERSION}/cli/conf.d/ && \

COPY ./deps /workdir/deps

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
