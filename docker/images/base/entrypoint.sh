#!/usr/bin/env bash

# Set the uid that php-fpm will run as if one was specified
if [ "$PHP_FPM_USER_ID" != "" ]; then
    usermod -u $PHP_FPM_USER_ID www-data
fi

# Set php.ini options
for TYPE in cli fpm; do
    PHP_INI=/etc/php/${PHP_VERSION}/${TYPE}/php.ini

    # Update the PHP upload_max_filesize setting if one was specified
    if [ "$PHP_UPLOAD_MAX_FILESIZE" != "" ]; then
        sed -i "s!upload_max_filesize = 2M!upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE!g" "$PHP_INI"
    fi

    # Update the post_max_size setting if one was specified
    if [ "$PHP_POST_MAX_SIZE" != "" ]; then
        sed -i "s!post_max_size = 8M!post_max_size = $PHP_POST_MAX_SIZE!g" "$PHP_INI"
    fi
done

if [ -z "$INTERACTIVE" ]; then
    /usr/bin/php "$@"
else
    "$@"
fi

