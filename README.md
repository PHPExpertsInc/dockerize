# Dockerize PHP

A utility for rapidly deploying [Docker](https://www.docker.com) for PHP apps.

Watch the zero-dependency installation video: https://youtu.be/d8o9p2DimME
Installing on a legacy PHP 5.6 app in 2 minutes: https://youtu.be/xZxaJcsbrWU

**This project has been tested against over 350,000 open-sourced Packagist packages (via the Bettergist Archiver project) and is compatible with 99.999% of them.**

Includes:
 * PHP 5.6, 7.0-7.4 + 8.0, 8.1, 8.2, 8.3, 8.4, and 8.5.
 * Nginx
 * Redis v7.2
 * PostgreSQL v16
 * MariaDB v10.11

Current PHP versions:

* PHP 5.6.40-103+ubuntu24.04.1+deb.sury.org+1 (cli)
* PHP 7.0.33-91+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Jul  3 2026 07:18:41) ( NTS )
* PHP 7.1.33-79+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Jul  3 2026 07:03:03) ( NTS )
* PHP 7.2.34-65+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Jul  3 2026 06:43:24) ( NTS )
* PHP 7.3.33-34+ubuntu24.04.1+deb.sury.org+1 (cli) (built: Jul  3 2026 06:35:16) ( NTS )
* PHP 7.4.33 (cli) (built: Jul  3 2026 06:09:47) ( NTS )
* PHP 8.0.30 (cli) (built: Jul  3 2026 05:51:50) ( NTS )
* PHP 8.1.34 (cli) (built: Jul  3 2026 05:36:20) (NTS)
* PHP 8.2.33 (cli) (built: Jul 30 2026 15:54:06) (NTS)
* PHP 8.3.33 (cli) (built: Jul 30 2026 15:39:15) (NTS)
* PHP 8.4.25 (cli) (built: Aug 28 2026 06:55:33) (NTS)
* PHP 8.5.10 (cli) (built: Aug 28 2026 06:46:18) (NTS)

## Image variants

Every shipped image is **distroless**: the published tags are `FROM scratch`
images containing only PHP, the selected extensions, their native dependencies
and a minimal set of POSIX utilities. The full Ubuntu images are never
published; they exist only during the build as intermediate "fat builders"
(`phpexperts/php-ubuntu:${PHP_VERSION}`, `-debug` and `-full`).

CLI images:

* `phpexperts/php:${PHP_VERSION}` — the standard distroless CLI.
* `phpexperts/php:${PHP_VERSION}-debug` — adds Xdebug.
* `phpexperts/php:${PHP_VERSION}-full` — adds every bundled PHP extension:
  imap, ldap, pspell, redis, snmp, xmlrpc, uuid, gd, imagick, memcached,
  msgpack, ssh2 and the rest of the Debian set.

The web images mirror the CLI variants:

* `phpexperts/web:nginx-php${PHP_VERSION}`
* `phpexperts/web:nginx-php${PHP_VERSION}-debug`
* `phpexperts/web:nginx-php${PHP_VERSION}-full`

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
    docker compose up -d

`vendor/bin/php` runs the PHP version selected by `PHP_VERSION` in `.env`, and
defaults to PHP 8.4 when that variable is not set.

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

#### v15.0.0: Distroless -debug and -full images

* **[2026-09-19 17:56:34 EEST]** Refreshed the apt index in the extension builder before installing deps.
* **[2026-09-19 17:18:48 EEST]** Noted that the maintainer maintains the changelog.
* **[2026-09-19 17:17:17 EEST]** Documented the distroless debug/full images.
* **[2026-09-19 17:17:11 EEST]** Added smoke tests for distroless debug/full variants.
* **[2026-09-19 17:00:00 EEST]** Added PHP 8.5 to the -full images.
* **[2026-09-19 16:28:01 EEST]** Fixed -full version and port handling in install.php.
* **[2026-09-19 16:24:33 EEST]** Retired build-distroless.sh and unified -full image naming.
* **[2026-09-19 16:24:04 EEST]** Reworked the image build pipeline for all distroless variants.
* **[2026-09-19 14:34:50 EEST]** Projected the CLI SAPI's PHP extensions onto PHP-FPM in the web images.
* **[2026-09-19 14:22:38 EEST]** Propagated /grab_files.sh failures for /usr/bin/bash in the distroless build.
* **[2026-09-19 14:06:04 EEST]** Propagated ldd failures with diagnostics in grab_files.sh.
* **[2026-09-19 14:01:12 EEST]** Marked the grab_files consolidation and hardening (IG-2) done.
* **[2026-09-19 13:59:52 EEST]** Consolidated the three grab_files.sh copies into one canonical script.
* **[2026-09-18 00:15:22 EEST]** Copied the /VERSION marker into the distroless web images.
* **[2026-09-17 23:57:32 EEST]** Guarded the web grab_files.sh scripts against empty ldd dependencies.
* **[2026-09-17 23:37:24 EEST]** Added per-commit tests and made the distroless -full build abort on grab failures.
* **[2026-09-17 23:33:16 EEST]** Added an AGENTS.md
* **[2026-09-17 20:23:07 EEST]** Preserved child exit status and cleaned up survivors on web entrypoints
* **[2026-09-17 20:21:26 EEST]** Propagated grab_files.sh failures in the full-image collection loop
* **[2026-09-17 20:20:37 EEST]** Detected missing ldd dependencies and aborted incomplete image builds
* **[2026-09-17 20:19:27 EEST]** Exec'd passthrough commands in the entrypoints for signal handling.
* **[2026-09-17 20:15:46 EEST]** Guarded the cleanup trap against set -e aborts.
* **[2026-09-17 20:15:01 EEST]** Removed the premature library copy from the distroless scripts.
* **[2026-09-17 20:07:19 EEST]** Rebuilt the php-ubuntu base in build-full-images.sh when missing.
* **[2026-09-17 20:01:03 EEST]** Stopped build-full-images.sh on Docker build failures.
* **[2026-09-17 19:59:22 EEST]** Routed nginx logs to stdout/stderr.
* **[2026-09-17 19:36:15 EEST]** Shared apt metadata via BuildKit cache mounts.
* **[2026-09-17 19:20:00 EEST]** Added a distroless nginx web image for -full PHP.
* **[2026-09-17 19:16:41 EEST]** Converted web-debug to a distroless image.
* **[2026-09-17 19:08:14 EEST]** Copied resolved ldd paths instead of basenames in grab_files.sh.
* **[2026-09-17 19:03:06 EEST]** Added missing libraries and data files to the distroless -full image.
* **[2026-09-17 19:03:06 EEST]** Added distroless build target for -full PHP images.
* **[2026-09-17 18:50:30 EEST]** Added distroless build target for -debug PHP images.
* **[2026-09-17 18:36:19 EEST]** Refactored base-debug/base-full into fat builder images.
* **[2026-09-17 18:36:17 EEST]** Parameterized the distroless Dockerfile by base image.

#### v14.2.0

* **[2026-09-17 17:57:25 EEST]** Added better PHP 8.5 support.
* **[2026-07-01 01:40:24 EEST]** Added some more essential terminal programs to the distroless image.
* **[2026-07-01 01:33:33 EEST]** Upped the default PHP CLI version to v8.4 if no other config.

#### v14.1.0

* **[2025-09-23 05:07:25 CDT]** Changed the default nginx listening port to 8000.
* **[2025-09-21 22:47:18 CDT]** [major] Added a distroless nginx web image.
* **[2025-09-21 22:35:18 CDT]** Embedded the default nginx virtualhost directly into the image.
* **[2025-09-21 22:11:07 CDT]** Added base POSIX utilities to the distroless image.
* **[2025-09-21 22:04:18 CDT]** [major] Made distroless the main form factor for containers.

#### v14.0.0: Distroless Images

* **[2025-08-16 19:07:33 CDT]** Upgraded to the latest PHP.
* **[2025-08-17 19:11:13 CDT]** [major] Converted all of the PHP base images to distroless, saving 500 MB per image.

#### v13.0.3
* **[2025-07-03 02:54:38 CDT]** Fixed the ext-builder.

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

For the full list, see the [[CHANGELOG.md]].

## Manage with docker compose

To control the containers, use `docker compose`.

    # Downloads the images, creates and launches the containers.
    docker compose up -d
    # View the logs
    docker compose logs -ft
    # Stop the containers
    docker compose stop

The first web service is published on <http://localhost:8000/>. The installer
starts from port 8000 and assigns `80xx` to each additional PHP version, so
it prints the exact URL when it finishes.

That's it! You now have the latest LEPP (Linux, Nginx, PostgreSQL, PHP) stack or
the latest LEMP (Linux, Nginx, MariaDB, PHP) stack.

# User ID control

It is possible to control what UID the initial process (usually PHP) and/or PHP-FPM processes run as. The `bin/php` file already does this for the initial process.

This is important if you are mounting a volumes into the container, as the the UID of the initial process or PHP-FPM will likely need to match the volume to be able to read and/or write to it.

## PHP-FPM process UID

To set the UID for the PHP-FPM process, you should set the `PHP_FPM_USER_ID` environmental variable on the container. e.g:

    docker run -e PHP_FPM_USER_ID=1000 phpexperts/php:7 php-fpm5.6

# Distribution

Docker Hub:
 * https://hub.docker.com/r/phpexperts/php/
 * https://hub.docker.com/r/phpexperts/web/

# About PHP Experts, Inc.

[PHP Experts, Inc.](https://www.phpexperts.pro/), is my consultation company. It's a small company of a half dozen
highly skilled Full Stack PHP devs, including myself, whom I place at 1099 positions at other corporations. We fill both
long-term positions and, for crazy devs like me, short-term. If you ever wanted to work on a different project/company
every few months or even weeks, anywhere in the continental U.S., Europe, or South East Asia, it's fantastic.

Since 2015, I have set up branches in Las Vegas, Houston, the UK, Dubai, Costa Rica, Colombia, India, and the Philippines.
If someone has a work auth in any of those places, we can place you almost anywhere you want. I travel 50% of the time
out of choice. All over the world.
