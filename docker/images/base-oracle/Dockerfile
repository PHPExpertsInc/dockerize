# phpexperts/php:7
ARG PHP_VERSION=8.1
FROM phpexperts/php:$PHP_VERSION
ARG PHP_VERSION
ENV PHP_VERSION $PHP_VERSION
ENV ORACLE_HOME=/opt/oracle/instantclient

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

## Change the mirror to Turkey, because I'm in UAE right now and it's damn slow.
#RUN sed -i -e 's#http://archive.ubuntu.com/ubuntu/#https://mirror.alastyr.com/ubuntu/ubuntu-archive/#' /etc/apt/sources.list

# PHP Versions:
# 7.x = oci8-2.2.0
# 8.0 = oci8-3.0.1
# 8.1 = oci8-3.2.1
# 8.2 = oci8-3.3.0
COPY .build-assets/${PHP_VERSION}/* \
     .build-assets/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip \
     .build-assets/instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip \
     /tmp

# Download oracle packages and install OCI8
RUN mkdir -p /opt/oracle && \
    unzip /tmp/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip && \
    mv instantclient_21_12    /opt/oracle/instantclient/ && \
    rm /tmp/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip && \
    unzip /tmp/instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip  && \
    mv instantclient_21_12/*  /opt/oracle/instantclient/ && \
    rm -r instantclient_21_12 /tmp/instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip  && \
    echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig && \
    echo "Finished setting up the Oracle SDK."

ENV LD_LIBRARY_PATH /opt/oracle/instantclient

COPY .build-assets/id_ed25519 /root/.ssh/id_ed25519

RUN apt-get update && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-pspell \
        php${PHP_VERSION}-snmp \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-xmlrpc \
        # Needed for ext-oci8 \
        libaio1 \
        && \
    # Install oci8.so directly, if it exists... \
    if [ -f /tmp/oci8.so ]; then \
        mv -v /tmp/oci8.so $(php -r 'echo ini_get("extension_dir");')/; \
    else \
        # Compile ext-oci8 \
        apt-get install -y build-essential php-pear php${PHP_VERSION}-dev && \
        pecl channel-update pecl.php.net && \
        echo "instantclient,/opt/oracle/instantclient" | pecl install pecl install $(cat /tmp/oci8.target) && \
        scp -o StrictHostKeyChecking=no $(php-config --extension-dir)/oci8.so tsmith@172.17.0.1:/code/dockerize/docker/images/base-oracle/.build-assets/${PHP_VERSION}/ && \
        rm -r /root/.ssh; \
    fi && \
    echo "extension=oci8.so" >> /etc/php/${PHP_VERSION}/mods-available/oci8.ini && \
    ln -s /etc/php/${PHP_VERSION}/mods-available/oci8.ini /etc/php/${PHP_VERSION}/cli/conf.d/ && \
    # Cleanup \
    apt remove -y build-essential php${PHP_VERSION}-dev php-pear && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/debconf/* && \
    #
    # Fix "Unable to create the PID file (/run/php/php5.6-fpm.pid).: No such file or directory (2)"
    mkdir -p /run/php
    #
    ## Configure PHP

