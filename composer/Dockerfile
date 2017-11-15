# chekote/php:7-composer
FROM chekote/php:7

RUN apt-get update && \
    apt-get install -y --no-install-recommends \

        # Composer requirements. See https://getcomposer.org/doc/00-intro.md#system-requirements
        git \
        php${PHP_VERSION}-zip && \

    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*
