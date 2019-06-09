# phpexperts/php:7
FROM archlinux/base:latest

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LC_ALL C.UTF-8

# Set correct locale
# From https://github.com/niklas-heer/arch-yay/
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8
ENV LC_CTYPE 'en_US.UTF-8'

# Prime the container.
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm sudo binutils core/make tar zip unzip git

# Add user, group sudo
# From https://github.com/niklas-heer/arch-yay/
RUN /usr/sbin/groupadd --system sudo && \
    /usr/sbin/useradd -m --groups sudo arch && \
    /usr/sbin/sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && \
    /usr/sbin/echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo "Installing the PHP ecosystem." && \

    # Install PHP & curl (for composer)
    pacman -S --noconfirm \
        php \
        vim iputils && \
    pacman -S --noconfirm \
        php-gd \
        php-memcached \
        php-pgsql \
        php-sqlite && \

    # Cleanup
    rm -rf /var/cache/pacman/pkg/* && \

    # Fix "Unable to create the PID file (/run/php/php5.6-fpm.pid).: No such file or directory (2)"
    mkdir /run/php 

COPY ./php.ini /etc/php
COPY ./phpredis.ini /etc/php/conf.d
COPY ./phpredis.ini /etc/php/conf.d

VOLUME ["/workdir"]
WORKDIR /workdir

EXPOSE 9000

COPY entrypoint.sh /usr/local/bin/entrypoint-php.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-php.sh"]
