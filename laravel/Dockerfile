# chekote/php:7-laravel
FROM chekote/php:7

RUN apt-get update && \
    apt-get install -y --no-install-recommends \

        # Composer requirements. See https://getcomposer.org/doc/00-intro.md#system-requirements
        git \
        php${PHP_VERSION}-zip \

        # Laravel requirements. See https://laravel.com/docs/5.4/installation#server-requirements
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mcrypt \
        php${PHP_VERSION}-xml && \

    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*

VOLUME ["/data"]
WORKDIR /data

ENTRYPOINT ["/bin/bash", "-c"]
