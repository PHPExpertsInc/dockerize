# chekote/php:7-behat
FROM chekote/php:7-composer

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \

        # Behat requirements
        php${PHP_VERSION}-mbstring \

        # instaclick/php-webdriver requirements
        php${PHP_VERSION}-curl && \

    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*
