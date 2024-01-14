# phpexperts/php:7
ARG PHP_VERSION=8.1
FROM phpexperts/php:$PHP_VERSION
ARG PHP_VERSION

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

## Change the mirror to Turkey, because I'm in UAE right now and it's damn slow.
#RUN sed -i -e 's#http://archive.ubuntu.com/ubuntu/#https://mirror.alastyr.com/ubuntu/ubuntu-archive/#' /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-pspell \
        php${PHP_VERSION}-snmp \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-xmlrpc && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/debconf/* && \
    #
    # Fix "Unable to create the PID file (/run/php/php5.6-fpm.pid).: No such file or directory (2)"
    mkdir -p /run/php
    #
