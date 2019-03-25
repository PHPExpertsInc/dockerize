#!/usr/bin/env bash

echo "Installing the MariaDB tools into bin/"
(cd bin; ln -sf stacks/mariadb/* .)

echo "Installing docker files..."
(cd docker/lib; sed -e "s/\${STACK}/lemp/" env.sh.dist > env.sh)

if [[ "$1" == "--dev" ]]; then
    ln -sf docker/docker-compose.nginxphp+maria+redis.dev.yml docker-compose.yml
else
    ln -sf docker/docker-compose.nginxphp+maria+redis.yml docker-compose.yml
fi
