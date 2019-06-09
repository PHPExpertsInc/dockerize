# phpexperts/php:7-laravel
FROM phpexperts/php:7

# Install yay - https://github.com/Jguer/yay
ENV yay_version=9.2.0
ENV yay_folder=yay_${yay_version}_x86_64
RUN cd /tmp && \
    curl -L https://github.com/Jguer/yay/releases/download/v${yay_version}/${yay_folder}.tar.gz | tar zx && \
    install -Dm755 ${yay_folder}/yay /usr/bin/yay && \
    install -Dm644 ${yay_folder}/yay.8 /usr/share/man/man8/yay.8 && \
    pacman -Sy && \
    pacman -S --noconfirm autoconf automake fakeroot gcc && \
    sudo -u arch yay -S --noconfirm --nodevel phpredis-git && \
    pacman -R --noconfirm autoconf automake gcc
