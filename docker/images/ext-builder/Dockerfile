#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2025 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################

FROM phpexperts/linux:latest

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

## Change the mirror to Turkey, because I'm in UAE right now and it's damn slow.
#RUN sed -i -e 's#http://archive.ubuntu.com/ubuntu/#https://mirror.alastyr.com/ubuntu/ubuntu-archive/#' /etc/apt/sources.list

# Download oracle packages and install OCI8
RUN apt-get update && apt-get install -y --no-install-recommends \
        php8.0-cli php8.1-cli php8.2-cli php8.3-cli php8.4-cli \
        php8.0-xml php8.1-xml php8.2-xml php8.3-xml php8.4-xml \
        php8.0-zip php8.1-zip php8.2-zip php8.3-zip php8.4-zip && \
    # Compile ext-uuid \
    apt-get install -y build-essential \
        php8.0-dev php8.1-dev php8.2-dev php8.3-dev php8.4-dev \
        php-pear && \
    pecl channel-update pecl.php.net
#    echo "instantclient,/opt/oracle/instantclient" | pecl install pecl install $(cat /tmp/oci8.target) && \
#    echo "extension=uuid" >> /etc/php/${PHP_VERSION}/mods-available/uuid.ini && \
#    ln -s /etc/php/${PHP_VERSION}/mods-available/uuid.ini /etc/php/${PHP_VERSION}/cli/conf.d/ && \

COPY ./deps /workdir/deps

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
