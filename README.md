# Dockerize PHP

A utility for rapidly deploying [Docker](https://www.docker.com) for PHP apps.

Watch the installation video: https://youtu.be/xZxaJcsbrWU

## This project has been tested against over 350,000 open-sourced Packagist packages and is compatible with 99.999% of them.

Includes: 
 * PHP 5.6, 7.0-7.4 + 8.0, 8.1, 8.2, and 8.3
 * Nginx
 * Redis v7.2
 * PostgreSQL v16
 * MariaDB v10.11
 * Oracle ext-oci

The `phpexperts/php:VESION-full` images contain every bundled PHP extension, and Redis.

* imap
* ldap
* pspell
* redis
* snmp
* xmlrpc

The `phpexperts/php:VERSION-oracle` images contain everything in the full image plus drivers for Oracle (ext-oci8),

If you need an extension that is not available in the `full` build, please create an Issue at GitHub.

# Advantages over other dockerized PHP projects

1. **Super fast, completely automated installation.** (Great for testing multiple versions on CIs)
2. The **BIG** difference between www.phpdocker.io and Dockerize PHP is that Dockerize PHP provides all of the client utilities, where phpdocker.io provides NONE of them.

Out of the box, you have per-project binaries:

 * **php**
 * **composer**
 * **php-ci.sh**
 * mysql
 * mysqldump
 * psql
 * pg_dump
 * createdb
 * dropdb
 * redis
 * redis-cli

# PHP CI via Docker

With the **php-ci.sh** shell script, you can easily test your app or library against every major version of PHP (currently 7.4-8.3):

In the project root directory, where your phpunit.xml is, or where you'd normally run phpunit:

    vendor/bin/php-ci.sh

It will then automagically update composer and run the appropriate version of PHPUnit for all of the major PHP versions
supported by your project via the power of Docker.

# Installation

* Watch the [**Installation HOWTO video**](https://youtu.be/xZxaJcsbrWU).

## Via Bash (Zero PHP dependencies)

    bash <(curl -s 'https://raw.githubusercontent.com/PHPExpertsInc/dockerize/v10.0/dockerize.sh')

Then edit credentials in .env.

    docker compose up -d

### Via Composer

    # Ensure that vendor/bin is in your PATH and before /usr/bin.
    composer require --dev phpexperts/dockerize
    vendor/bin/php dockerize
    # Edit credentials in .env.
    docker-compose up -d

Don't forget to edit your docker-compose.yml!

### Configure your PATH

In order to dockerize your existing PHP project, do the following:

Ensure that your profile PATH includes `./vendor/bin` and that it takes priority over any other directory that may include a php executable:

    PATH=./vendor/bin:$PATH

## Latest Changes

## v10.0.3
* **[2024-06-29 10:13:12 CDT]** [php-ci] Dynamically fetch and compute the supported PHP versions from the composer.json.
* **[2024-06-29 10:20:39 CDT]** [php-ci] Use phpunit's default config if there aren't version-specific xmls.
* **[2024-06-29 10:20:48 CDT]** [php-ci] Added support for PHPUnit v11.
* **[2024-06-29 10:31:50 CDT]** Create a Packagist alias to phpexperts/dockerise for SEO.

### v10.0.2
* **[2024-06-26 00:57:05 CDT]** Added my php-ci.sh script.

#### v10.0.0
* **[2024-05-24 07:40:15 CDT]** Added a comprehensive zero-dependency Bash-via-curl installer.
* **[2024-05-24 07:31:26 CDT]** Added a mechanism for finding the first open HTTP port for nginx. master
* **[2024-05-24 07:30:16 CDT]** Redis removed v7.3 from docker; switched to v7.2.

#### v9.2.1
* **[2024-05-23 08:17:00 CDT]** Upgraded to MariaDB 10.11, Redis 7.3, and Postgres 16.

#### v9.2.0
* **[2024-05-21 21:31:26 CDT]** Configured it so that composer will run the install script. 

#### v9.1.2
* **[2024-05-21 06:27:48 CDT]** Fixes docker logs being truncated. origin/v9.

#### v9.1.1
* **[2024-01-16 03:15:49 CST]** [major] Fixed a critical bug that prevented the dockerized php CLI from running in projects with a defined network.
* **[2024-01-14 14:22:31 CST]** Fixed the Docker installer.
* **[2024-01-14 14:13:58 CST]** Renamed the installer.
* **[2024-01-14 14:12:02 CST]** Switched the installer from wget to curl.

#### v9.1.0: New zero-dependency Bash Installer
* **[2024-01-14 07:06:07 CST]** Added a zero-PHP-dependency Bash installer.
* **[2024-01-14 07:04:47 CST]** Added support for Linux ACLs in the base Linux image.
* **[2024-01-14 07:03:35 CST]** Fixed docker building bugs in base-oracle.

#### v9.0.1:
* **[2024-01-14 06:40:56 CDT]** [major] Fixed a critical bug that prevented the dockerized php CLI from running in new projects.

#### v9.0.0: Version 9.0.0: New full PHP image, Oracle ext-oci8, and a new build system.
* **[2024-01-13 23:04:49 CST]** Added the Oracle ext-oci8 binaries, built against Ubuntu 22.04.
* **[2024-01-13 22:51:39 CST]** Added a  docker build that contains the Oracle DB's ext-oci8 extension.
* **[2024-01-13 22:50:16 CST]** Added wget to the base PHP image.
* **[2024-01-12 17:30:47 CST]** Refactored IonCube builds so that the extension is only downloaded once.
* **[2024-01-12 14:49:27 CST]** Added a `full` docker build that contains every bundled PHP extension, and then some.

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
