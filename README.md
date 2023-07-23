# Dockerize PHP

A utility for rapidly deploying [Docker](https://www.docker.com) for PHP apps.

Watch the installation video: https://youtu.be/xZxaJcsbrWU

Includes: 
 * PHP v7.0-7.4 + 8.0, 8.1, 8.2
 * Nginx
 * Redis
 * PostgreSQL v15
 * MariaDB v10.5

# Advantages over other dockerized PHP projects

1. **Super fast, completely automated installation.** (Great for testing multiple versions on CIs)
2. The **BIG** difference between www.phpdocker.io and Dockerize PHP is that Dockerize PHP provides all of the client utilities, where phpdocker.io provides NONE of them.

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

* Watch the [**Installation HOWTO video**](https://youtu.be/xZxaJcsbrWU).

### Via Composer

    composer require phpexperts/dockerize
    vendor/phpexperts/dockerize/install.php
    docker-compose up -d

### Via GitHub

    git clone https://github.com/PHPExpertsInc/dockerize-php.git
    cd docker-php-stack
    bin/php install.php
    docker-compose up -d
    
Don't forget to edit your docker-compose.yml!

### Configure your PATH

In order to dockerize your existing PHP project, do the following:

Ensure that your profile PATH includes `./vendor/bin` and that it takes priority over any other directory that may include a php executable:

    PATH=./vendor/bin:$PATH

## Latest Changes

### v8.0.1
* **[2023-01-20 21:58:20 CDT]** Fixed the problem that prevented the web images from being successfully built.

### v8.0.0
* **[2022-08-11 00:37:03 CDT]** Boosted the default version of PHP to 8.1.
* **[2022-08-11 00:37:33 CDT]** Added PHP v8.2 support. master
* **[2023-01-17 06:59:14 CDT]** Cleaned up the build script so that it tags instead of building duplicate images.
* **[2023-01-17 07:00:57 CDT]** Improved the Linux base image build.
* **[2023-01-17 08:46:09 CDT]** Explicitly set the default PHP version to 8.1.
* **[2023-01-17 07:41:52 CDT]** Now, PHP will be launched from a continuously-running container for much faster runtimes at the expense of about 130 MB per container.
* **[2023-01-17 08:57:42 CDT]** Added support for PHP 8.2.

## Manage with docker-compose

To control the containers, use `docker-compose`.
  
    # Downloads the images, creates and launches the containers.
    docker-compose up -d
    # View the logs
    docker-compose logs -ft
    # Stop the containers
    docker-compose stop

That's it! You now have the latest LEPP (Linux, Nginx, PostgreSQL, PHP) stack or
the latest LEMP (Linux, Nginx, MariaDB, PHP) stack.

# User ID control

It is possible to control what UID the initial process (usually PHP) and/or PHP-FPM processes run as. The `bin/php` file already does this for the initial process.

This is important if you are mounting a volumes into the container, as the the UID of the initial process or PHP-FPM will likely need to match the volume to be able to read and/or write to it.

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
