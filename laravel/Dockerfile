# chekote/php:7-laravel
FROM chekote/php:7

ENV LC_ALL en_US.UTF-8

# Install packages
RUN apt-get update && \
    apt-get install -y php${PHP_VERSION}-curl && \
    apt-get install -y php${PHP_VERSION}-mbstring && \
    apt-get install -y php${PHP_VERSION}-mcrypt && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/data"]
WORKDIR /data

ENTRYPOINT ["/bin/bash", "-c"]
