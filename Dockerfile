FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8

# Setup repositories
RUN apt-get update && \
    apt-get install -y software-properties-common python-software-properties && \
    apt-get install -y language-pack-en-base && \
    add-apt-repository ppa:ondrej/php-7.0 && \

# Install packages
    apt-get update && \
    apt-get install -y php7.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/data"]
WORKDIR /data
