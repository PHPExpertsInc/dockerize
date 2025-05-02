# Dockerize PHP

A utility for rapidly deploying [Docker](https://www.docker.com) for PHP apps.

Watch the zero-dependency installation video: https://youtu.be/d8o9p2DimME  
Installing on a legacy PHP 5.6 app in 2 minutes: https://youtu.be/xZxaJcsbrWU

**This project has been tested against over 350,000 open-sourced Packagist packages (via the Bettergist Archiver project) and is compatible with 99.999% of them.**

Includes: 
 * PHP 5.6, 7.0-7.4 + 8.0, 8.1, 8.2, 8.3, and 8.4.
 * Nginx
 * Redis v7.2
 * PostgreSQL v16
 * MariaDB v10.11

Current PHP versions: 
 * 5.6.40-81+ubuntu24.04.1+deb.sury.org+1
 * 7.0.33-79+ubuntu24.04.1+deb.sury.org+1
 * 7.1.33-67+ubuntu24.04.1+deb.sury.org+1
 * 7.2.34-54+ubuntu24.04.1+deb.sury.org+1
 * 7.3.33-24+ubuntu24.04.1+deb.sury.org+1
 * 7.4.33
 * 8.0.30
 * 8.1.32
 * 8.2.28
 * 8.3.20
 * 8.4.6

The `phpexperts/php:VESION-full` images contain every bundled PHP extension, and Redis.

* imap
* ldap
* pspell
* redis
* snmp
* xmlrpc
* Oracle ext-oci

The `phpexperts/php:VERSION-full` images contain everything in the full image plus drivers for Oracle (ext-oci8),

If you need an extension that is not available in the `full` build, please create an Issue at GitHub.

# Installation

* Watch the [**Installation HOWTO video**](https://youtu.be/xZxaJcsbrWU).

* Here's another Zero Install demo including PHP 8.4 and the php-ci system for testing every version of PHP.

[![phpexperts/dockerize Demo](https://private-user-images.githubusercontent.com/1125541/395483191-6dc866ed-b2fb-4262-98fe-2f8dbaa1e76f.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MzQwNzgxNDgsIm5iZiI6MTczNDA3Nzg0OCwicGF0aCI6Ii8xMTI1NTQxLzM5NTQ4MzE5MS02ZGM4NjZlZC1iMmZiLTQyNjItOThmZS0yZjhkYmFhMWU3NmYucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MTIxMyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDEyMTNUMDgxNzI4WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ZTFiOGM0ZDFkMTRlMmUwNTJmOWM5ZDA5M2U2OWU5NDFlOTk4ZTc2YmIwMmZiZjAyYmY3ZTZhMjI3OWRlZmIwMiZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.747HeCQJJpg9Snd93a0BECrVAF9-_lDwm-E32-d69nM)](https://youtu.be/rCfmTH62-os)

## Via Bash (Zero PHP dependencies)

    bash <(curl -s 'https://raw.githubusercontent.com/PHPExpertsInc/dockerize/v12.x/dockerize.sh')

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

## Thank you, JetBrains

JetBrains generously grants this project a free Open-Source License to PhpStorm and all other JetBrains products as part of its [Open Source License](https://www.jetbrains.com/community/opensource/) initiative.

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

## Latest Changes

#### v13.0.2
* **[2025-05-01 19:09:42 CDT]** Version 13.0.2: Fixed the .gitattributes.

#### v13.0.1
* **[2025-04-21 00:04:11 CDT]** [php-ci] Fixed a bug.

#### v13.0.0
* **[2025-04-17 06:21:56 CDT]** Downverted the composer version constraints system to PHP 7.0.0 compatibility, with polyfills.
* **[2025-04-17 05:56:47 CDT]** [m] Version bumped the PHP versions.
* **[2025-04-17 05:08:34 CDT]** Completely reimplemented the PHP version parser.
* **[2025-03-26 11:15:21 CDT]** [m] Renamed test/ to tests/.
* **[2025-03-26 10:45:57 CDT]** Removed unnecessary distributables from composer install.
* **[2025-03-26 10:35:51 CDT]** Moved the web root to public/.
* **[2025-03-26 09:51:14 CDT]** Added ext-uuid to the extension builder system.
* **[2025-03-26 09:40:29 CDT]** Completely reimplemented the PHP extension builder to use only 1 image for all PHP versions.
* **[2025-03-26 08:21:47 CDT]** [bin/php] Optimized further when running natively and inside docker.
* **[2025-03-25 13:21:46 CDT]** Added the PHP Extension Builder system.
* **[2025-03-25 13:10:50 CDT]** [linux] Added the en_US.UTF-8 locale so more apps will work.
* **[2025-03-25 13:08:48 CDT]** Added steps to download ext-uuid source code.
* **[2025-03-25 13:04:45 CDT]** Ignore all .build-assets/ directories.
* **[2025-03-24 13:34:41 CDT]** [fixed] Ensured proper command execution in the entrypoint.
* **[2025-03-24 13:33:11 CDT]** [bin/php] Sets the working directory of the CLI to the current project directory.
* **[2025-03-24 13:32:15 CDT]** [bin/php] Default to host network if no project network exists
* **[2025-03-24 13:31:12 CDT]** [bin/php] Propagate the exit code from native php execution.

#### v12.2.1
* **[2025-03-24 13:20:03 CDT]** [bin/php] Complete fixed native PHP dispatching.

#### v12.2.0
* **[2025-03-23 00:33:11 CDT]** Fixed a bug where the native PHP binary couldn't find files.

#### v12.1.2
* **[2024-12-21 13:32:23 CDT]** Improved PHP 8.4 support.
* **[2025-03-17 16:31:30 CDT]** Built PHP 8.1.32, 8.2.28, 8.3.19, 8.4.5. HEAD -> v12.x

#### v12.1.1
* **[2025-03-13 17:25:06 CDT]** [php-ci] Refactored a lot.

#### v12.1.0
* **[2025-03-12 18:32:13 CDT]** Upgraded PHP 8.3.17 and 8.4.4.
* **[2025-03-12 17:50:58 CDT]** Renabled build support for PHP 5.6-7.3.
* **[2025-03-12 17:45:01 CDT]** [php-ci] Added support for PHPUnit v12.
* **[2025-03-12 17:37:04 CDT]** [php-ci] Added PHPUnit support for PHP 7.0 and 7.1.

#### v12.0.2
* **[2025-01-07 08:11:57 CST]** Fixed a bug where native PHP detection via .env didn't work.
* **[2024-12-13 02:18:41 CST]** Added another YouTube demo.

#### v12.0.1
* **[2024-12-13 01:51:43 CST]** Added PHP 8.4 support to php-ci.sh HEAD -> v12.x, origin/v12.x

#### v12.0.0
* **[2024-12-12 16:19:40 CST]** Added support for PHP 8.4.
* **[2024-12-12 23:55:18 CST]** Majorly overhauled the dockerize installer.

#### v11.1.0
* **[2024-09-26 07:37:40 CDT]** Add composer to the PHP 8.4 image. HEAD -> v11.0
* **[2024-09-26 07:36:44 CDT]** Fixed the PHP 8.4 entrypoint to use the standard entrypoint.
* **[2024-09-13 03:48:00 CDT]** Added support for PHP 8.4 beta5.
* **[2024-09-12 05:30:37 CDT]** [m] Updated the README.
* **[2024-09-12 01:58:49 CDT]** [m] Use the new ENV format in the Dockerfiles.
* **[2024-09-12 01:44:09 CDT]** Fixes for PHP 8.4 beta4 builds.
* **[2024-09-09 12:55:33 CDT]** [m] Prioritized the installation instructions in the README.md.

#### v11.0.0
* **[2024-09-07 18:55:07 CDT]** [major] Upgraded to Ubuntu 24.04 Noble Numbat.
* **[2024-09-07 18:55:45 CDT]** Fixed a major reversion in web-debug by readding php-fpm.
* **[2024-09-07 17:20:24 CDT]** Added initial steps for creating a distroless PHP image. origin/v11.0
* **[2024-09-07 19:00:42 CDT]** Use a docker volume to store apt metadata.
* **[2024-08-05 03:46:54 CDT]** Added support for PHP 8.4 Alpha 4.
* **[2024-08-05 04:33:33 CDT]** Added a bash installation script to the composer package.

#### v10.0.3
* **[2024-06-29 10:13:12 CDT]** [php-ci] Dynamically fetch and compute the supported PHP versions from the composer.json.
* **[2024-06-29 10:20:39 CDT]** [php-ci] Use phpunit's default config if there aren't version-specific xmls.
* **[2024-06-29 10:20:48 CDT]** [php-ci] Added support for PHPUnit v11.
* **[2024-06-29 10:31:50 CDT]** Create a Packagist alias to phpexperts/dockerise for SEO.

#### v10.0.2
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

# Exact PHP Versions 

PHP 5.6.40-81+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Dec 24 2024 06:43:22) ( NTS )
PHP 7.0.33-79+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Dec 24 2024 06:43:22) ( NTS )
PHP 7.1.33-67+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Dec 24 2024 06:50:54) ( NTS )
PHP 7.2.34-54+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Dec 24 2024 06:58:15) ( NTS )
PHP 7.3.33-24+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Dec 24 2024 07:05:25) ( NTS )
PHP 7.4.33 (cli) (built: Dec 24 2024 07:12:16) ( NTS )
PHP 8.0.30 (cli) (built: Dec 24 2024 07:19:59) ( NTS )
PHP 8.1.31 (cli) (built: Nov 21 2024 13:10:45) (NTS)
PHP 8.2.27 (cli) (built: Dec 24 2024 06:29:37) (NTS)
PHP 8.3.17 (cli) (built: Feb 15 2025 09:09:25) (NTS)
PHP 8.4.4 (cli) (built: Feb 15 2025 08:59:26) (NTS)

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
