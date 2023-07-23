FROM ubuntu:jammy

# Fix add-apt-repository is broken with non-UTF-8 locales, see https://github.com/oerdnj/deb.sury.org/issues/56
ENV LANG=C.UTF-8 \ LC_ALL=C.UTF-8 \ DEBIAN_FRONTEND=noninteractive

## Change the mirror to Turkey, because I'm in UAE right now and it's damn slow.
#RUN sed -i -e 's#http://archive.ubuntu.com/ubuntu/#https://mirror.alastyr.com/ubuntu/ubuntu-archive/#' /etc/apt/sources.list

RUN echo "Building base Linux..." && \
    apt-get update -y && \
    # Configure ondrej PPA
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get upgrade -y && \
    #
    # Install PHP & curl (for composer)
    apt-get install -y --no-install-recommends \
        curl git ssh  \
        less vim inetutils-ping zip unzip net-tools

WORKDIR /workdir

ENTRYPOINT ["bash", "-l"]
