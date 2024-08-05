#!/bin/bash

#PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3"
PHP_VERSIONS="8.1 8.2 8.3"
#PHP_VERSIONS="8.2"
cd images

export BUILDKIT_STEP_LOG_MAX_SIZE=104857600

# Build the base linux image first.
export DOCKER_BUILDKIT=1

docker rmi --force phpexperts/linux:latest
docker build linux --tag="phpexperts/linux:latest" --no-cache --progress=plain
docker tag phpexperts/linux:latest phpexperts/linux:$(date '+%Y-%m-%d')

# Download build assets
## IonCube
if [ ! -f ./base-ioncube/.build-assets/ioncube_loaders_lin_x86-64.tar.gz ]; then
    echo "Downloading IonCube..."
    curl -LO https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
    mv ioncube_loaders_lin_x86-64.tar.gz ./base-ioncube/.build-assets/
fi

# Oracle OCI8
if [ ! -f ./base-oracle/.build-assets/instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip ]; then
    echo "Downloading Oracle's Instantclient + SDK..."
    curl -LO https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip
    mv instantclient-basic-linux.x64-21.12.0.0.0dbru.zip ./base-oracle/.build-assets/
    curl -LO https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip
    mv instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip ./base-oracle/.build-assets/
fi

for VERSION in ${PHP_VERSIONS}; do
  MAJOR_VERSION=${VERSION%.*}

#  docker rm $(docker ps -aq)
  docker rmi --force phpexperts/php:latest 2> /dev/null
  docker rmi --force phpexperts/php:latest-debug 2> /dev/null
  docker rmi --force phpexperts/php:${MAJOR_VERSION}-debug 2> /dev/null
  docker rmi --force phpexperts/php:${MAJOR_VERSION} 2> /dev/null
  docker rmi --force phpexperts/php:${VERSION} 2> /dev/null
  docker rmi --force phpexperts/php:${VERSION}-debug 2> /dev/null

  docker rmi --force phpexperts/web:nginx-php${VERSION} 2> /dev/null
  docker rmi --force phpexperts/web:nginx-php${VERSION}-debug 2> /dev/null
  docker rmi --force phpexperts/web:nginx-php${VERSION}-ioncube 2> /dev/null

  docker build base       --tag="phpexperts/php:latest"                    --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  docker tag phpexperts/php:latest "phpexperts/php:${MAJOR_VERSION}"
  docker tag phpexperts/php:latest "phpexperts/php:${VERSION}"

  docker rmi --force phpexperts/php:${VERSION}-full
  docker build base-full  --tag="phpexperts/php:${VERSION}-full"           --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain

  cp ~/.ssh/id_ed25519 base-oracle/.build-assets/
  docker rmi --force phpexperts/php:${VERSION}-oracle
  docker build base-oracle  --tag="phpexperts/php:${VERSION}-oracle"           --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  rm -f base-oracle/.build-assets/id_ed25519

  docker build base-debug --tag="phpexperts/php:latest-debug"              --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  docker tag phpexperts/php:latest-debug "phpexperts/php:${MAJOR_VERSION}-debug"
  docker tag phpexperts/php:latest-debug "phpexperts/php:${VERSION}-debug"

  docker tag "phpexperts/php:${VERSION}" phpexperts/php:latest
  docker build web        --tag="phpexperts/web:nginx-php${VERSION}"       --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  docker build web-debug  --tag="phpexperts/web:nginx-php${VERSION}-debug" --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain


  # IonCube doesn't support PHP v8.0 or v8.3.
  if [[ "$VERSION" != "8.0" && "$VERSION" != "8.3" ]]; then
    echo "Building IonCube for PHP v${VERSION}"
    docker build base-ioncube --tag="phpexperts/php:${VERSION}-ioncube"          --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
    docker build web-ioncube  --tag="phpexperts/web:nginx-php${VERSION}-ioncube" --build-arg PHP_VERSION=$VERSION --no-cache --progress=plain
  fi
done

#docker rmi --force phpexperts/php:8.2 phpexperts/web:nginx-php8.2
#docker build base-php8 --tag="phpexperts/php:8.2" --no-cache --progress=plain

#docker build web-php8 --tag="phpexperts/web:nginx-php8.2" --no-cache --progress=plain
