# chekote/php:7-laravel
FROM chekote/php:7

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8

# Install packages
RUN apt-get update && \
    apt-get install -y php7.0-curl && \
    apt-get install -y php7.0-mbstring && \
    apt-get install -y php7.0-mcrypt && \
    apt-get install -y php7.0-mysql && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/data"]
WORKDIR /data

ENTRYPOINT ["/bin/bash", "-c"]
