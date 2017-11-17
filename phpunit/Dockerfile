# chekote/php:7-phpunit
FROM chekote/php:7-composer

RUN apt-get update && \
    apt-get install -y --no-install-recommends \

        # PHPUnit requirements. See https://phpunit.de/manual/6.4/en/installation.html#installation.requirements
        php${PHP_VERSION}-dom \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-tokenizer \
        php${PHP_VERSION}-xdebug \
        php${PHP_VERSION}-xmlwriter && \

    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*
