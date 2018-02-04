# Docker image for PHP

A [Docker](https://www.docker.com) image for the [PHP](https://secure.php.net/) Command Line scripting language.

Includes: 
 * PHP v7.2.2, built on 1 Feb 2018
 * Nginx v1.10.3
 * Redis v3.2.6
 * PostgreSQL v9.6.6
 * MariaDB 10.3.4

# Advantages over other dockerized PHP projects

1. **Super fast, completely automated installation.** (Great for testing multiple versions on CIs)

        wget https://github.com/phpexpertsinc/docker-php/releases/download/v1.0%2Bphp-7.2.2/phppro-dockerized_php-v1.0.0.tar.gz
        tar xzvf phppro-dockerized_php-v1.0.0.tar.gz
        cp -rvf phppro-dockerized_php-v1.0.0/postgres/* .
        bin/containers up

2. The **BIG** difference between www.phpdocker.io and DockerPHP is that DockerPHP provides all of the client utilities, where phpdocker.io provides NONE of them.

Out of the box, you have per-project binaries:

* **php**
* mysql
* mysqldump
* psql
* pg_dump
* createdb
* dropdb
* redis
* redis-cli

# Installation

* Watch the [**Installation HOWTO video**](https://vimeo.com/254179137).

In order to dockerize your existing PHP project, do the following:

  1. Copy the contents of the `dist/mariadb` or `dist/postgres` directory into your project's root directory.
  2. Ensure that your profile PATH includes `./bin` and that it takes priority over any other directory that may include a php executable:

         PATH=./bin:$PATH

     Now whenever you are in your project's directory, you can simply execute `php` as you would with a typical composer installation, and the command will execute in the container instead:

         php -r 'phpinfo();'

  3. Change the database credentials in `docker-compose.base.yml`.
  4. Change the REDIS_PASSWORD in `docker/lib/env.sh`.
  5. To control the containers, use the `containers` docker wrapper.
  
         # Downloads the images, creates and launches the containers.
         containers up -d
         # View the logs
         containers logs -ft
         # Stop the containers
         containers stop

That's it! You now have the latest LEPP (Linux, Nginx, PostgreSQL, PHP) stack or
the latest LEMP (Linux, Nginx, MariaDB, PHP) stack.

# User ID control

It is possible to control what UID the initial process (usually PHP) and/or PHP-FPM processes run as. The `bin/php` file already does this for the initial process.

This is important if you are mounting a volumes into the container, as the the UID of the initial process or PHP-FPM will likely need to match the volume to be able to read and/or write to it.

Note: You should _NOT_ try to set the UID using Dockers -u or --user option, as this does not ensure that the user actually exists (entry in `/etc/passwd` home directory etc).

## Initial process UID

To set the UID for the initial process, you should set a `LOCAL_USER_ID` environmental variable on the container. e.g:

    docker run -e LOCAL_USER_ID=1000 phpexperts/php:7 -a php -v

## PHP-FPM process UID

To set the UID for the PHP-FPM process, you should set the `PHP_FPM_USER_ID` environmental variable on the container. e.g:

    docker run -e PHP_FPM_USER_ID=1000 phpexperts/php:7 php-fpm5.6

# php.ini directives

You can modify certain php.ini directives by setting environmental variables within the container. The following is a list of environmental variables and the php.ini directives that they correspond to:

| environmental variable  | php.ini directives                                                                       |
|-------------------------|---------------------------------------------------------------------------------------|
| `PHP_POST_MAX_SIZE`       | [`post_max_size`](http://php.net/manual/en/ini.core.php#ini.post-max-size)              |
| `PHP_UPLOAD_MAX_FILESIZE` | [`upload_max_filesize`](http://php.net/manual/en/ini.core.php#ini.upload-max-filesize)  |

e.g. the following will start a PHP container with the `post_max_size` to 30 Megabytes:

`docker run -e PHP_POST_MAX_SIZE=30M phpexperts/php:7`

# Distribution

Docker Hub:
 * https://hub.docker.com/r/phpexperts/php/
 * https://hub.docker.com/r/phpexperts/web/

# About PHP Experts, Inc.

[PHP Experts, Inc.](https://www.phpexperts.pro/), is my consultation company. It's a small company of a half dozen 
highly skilled Full Stack PHP devs, including myself, whom I place at 1099 positions at other corporations. We fill both 
long-term positions and, for crazy devs like me, short-term. If you ever wanted to work on a different project/company 
every few months or even weeks, anywhere in the continental U.S., Europe, or South East Asia, it's fantastic.  

Since 2015, I have set up branches in Las Vegas, Houston, the UK, Dublin, Costa Rica, Colombia, India, and the Philippines. 
If someone has a work auth in any of those places, we can place you almost anywhere you want. I travel 50% of the time 
out of choice. All over the world.

Plus, no taxes if you spend 6+ months (or a year, if you're American) out of your country. 

Did I mention that you get paid in the cryptocurrency of your choice?