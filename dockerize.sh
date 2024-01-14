#!/bin/bash

mkdir -p ./vendor/bin
if [ ! -f ./vendor/bin/composer ]; then
    echo "Downloading phpexperts/dockerize's php CLI launcher..."
    curl https://raw.githubusercontent.com/PHPExpertsInc/dockerize/master/bin/composer -o vendor/bin/composer
    echo "Downloading phpexperts/dockerize's composer CLI launcher..."
    curl https://raw.githubusercontent.com/PHPExpertsInc/dockerize/master/bin/php -o vendor/bin/php
    chmod 0755 ./vendor/bin/composer ./vendor/bin/php
fi
hash -r

if ! echo $PATH | grep -q ./vendor/bin; then
    echo 'You do not have ./vendor/bin in your $PATH.'
    echo 'Modern PHP apps and phpexperts/dockerize require this.'

    if [ ! -f ${HOME}/.bashrc ]; then
        echo "ERROR: It doesn't look like you are using bash (no ~/.bashrc file)."
        echo "       Please add ./vendor/bin to the PATH manually."
        exit 1
    fi

    echo ''
    echo -n 'May I add it to the front of your $PATH? (y/n) '
    read YES_OR_NO
    echo ''

    if [ $YES_OR_NO == 'y' ]; then
        echo 'Adding ./vendor/bin to your $PATH'
        echo '# Added by phpexperts/dockerize' >> ~/.bashrc
        echo 'PATH=./vendor/bin:$PATH' >> ~/.bashrc

        echo 'Your $PATH has been updated. You need you start a new shell now.'
        exit 2
    else
        echo "You can run Dockerized PHP manually:"
        echo ""
        echo "     ./vendor/bin/php"
        echo "     ./vendor/bin/composer"
    fi
fi

# See if they already have phpexperts/dockerize installed via composer...
# If not, install it...
composer show phpexperts/dockerize > /dev/null 2>&1 || composer require --ignore-platform-reqs --dev phpexperts/dockerize

cp /code/dockerize/install.php vendor/phpexperts/dockerize
./vendor/phpexperts/dockerize/bin/php ./vendor/phpexperts/dockerize/install.php

