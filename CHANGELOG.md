## v8.1.0
* **[2023-07-23 03:21:22 CDT]** Now Dockerize PHP will run in the container, if it's running, or create a temp one if it's not.
* **[2023-05-19 05:35:27 CDT]** Updated to PHP v8.0.28, v8.1.19, and v8.2.6.
* **[2023-05-19 05:30:36 CDT]** Changed the default image from PHP v7.4 to v8.0.
* **[2023-02-03 07:19:37 CST]** Majorly refactored so that it executes a persistent container for native launch speeds.

## v8.0.1
* **[2023-01-20 21:58:20 CST]** Fixed the problem that prevented the web images from being successfully built.

## v8.0.0
* **[2022-08-11 00:37:03 CDT]** Boosted the default version of PHP to 8.1.
* **[2022-08-11 00:37:33 CDT]** Added PHP v8.2 support. master
* **[2023-01-17 06:59:14 CST]** Cleaned up the build script so that it tags instead of building duplicate images.
* **[2023-01-17 07:00:57 CST]** Improved the Linux base image build.
* **[2023-01-17 08:46:09 CST]** Explicitly set the default PHP version to 8.1.
* **[2023-01-17 07:41:52 CST]** Now, PHP will be launched from a continuously-running container for much faster runtimes at the expense of about 130 MB per container.
* **[2023-01-17 08:57:42 CST]** Added support for PHP 8.2.

## v7.2.1
* **[2022-06-18 00:05:57 CDT]** Show all of the output of docker build, not just the last 6 lines.
* **[2022-06-18 00:10:05 CDT]** Upgraded to Ubuntu 22.04 Jammy Jellyfish.

## v7.2.0
* **[2021-12-27 12:05:54 CST]** Use the official PHP 8.1 builds now.
* **[2021-12-27 12:06:15 CST]** Include ext-imap and ext-ssh2.
* **[2021-12-27 17:18:50 CST]** (#10) Added support for the Ioncube Decoder.
* **[2021-12-27 17:22:18 CST]** Force the rebuilding of the Linux base image, for an up-to-date OS.
* **[2021-12-27 17:26:25 CST]** Added basic automated tests.

## v7.1.2
* **[2021-12-24 23:27:47 CST]** Added support for composer v2.2.0+.

## v7.1.1
* **[2021-12-24 16:09:16 CST]** Added xdebug support for PHP 8.1.
* **[2021-12-24 16:09:02 CST]** Upgraded to PHP v7.4.27, 8.0.14, and 8.1.1.
* **[2021-12-24 15:36:38 CST]** Fixed the ability of selecting the PHP version via the .env file.

## v7.1.0
* **[2021-12-10 08:32:27 CST]** Added install support for PHP 5.6, 8.0, and 8.1.
* **[2021-11-18 04:13:15 CST]** Added the ability to configure the Docker platform via the .env.
* **[2021-11-18 04:10:49 CST]** Upgraded the config files for Xdebug v3.0.

## v7.0.0
* **[2021-11-02 15:47:49 CST]** PHP 8.1 RC5.
* **[2021-11-01 08:08:36 CST]** Dramatically reduced total build time from 33 minutes to 11 minutes.
* **[2021-11-01 06:24:52 CST]** Embedded composer into the php container.
* **[2021-11-01 06:00:30 CST]** Run the native PHP when inside docker.
* **[2021-07-29 07:13:12 CDT]** Set the PHP memory_limit to unlimited by default.
* **[2021-07-29 07:07:35 CDT]** Fixed the building of xdebug.
* **[2021-06-21 07:10:58 CDT]** Added git and ssh for private packages supoprt.

## v6.6.0
* [2021-09-22 08:40:22 CDT] - Added the abiltiy to run commands in containers from the CLI.

## v6.5.0
* [2021-06-03 08:22:27 CDT] - Installed the SOAP extension.
* [2021-06-03 08:37:10 CDT] - Major improvements to the php cli.

## v6.4.1
* [2021-02-05] Upgraded to PHP v8.0.1, v7.4.14, and v7.3.26
* [2021-02-05] Added a Docker Hub release script.

## v6.4.0
* [2020-12-03] Upgraded to PHP v8.0.0

## v6.2.1

* [2020-10-30] Upgraded to PHP v8.0 RC3.

## v6.2.0

* [2020-10-04] Upgraded to PHP v8.0 RC1.
* [2020-10-04] Fixed the extension_dir location so PHP extensions work.
* [2020-10-04] Installed the Zend Opcache extension.
* [2020-10-04] Installed the PHPRedis extension.
* [2020-10-04] Stripped out the debug symbols for massive space savings.
* [2020-09-19] Upgraded to PHP v8.0 Beta 4.

## v6.1.0: 

 * [2020-09-10] Added the ability to dynamically pick what PHP version is run via $PHP_VERSION.
 * [2020-09-10] Run the system's native PHP via $PHP_VERSION="native".

## v6.0.0: 2020-09-10

 * [2020-09-09] Upgraded to Ubuntu Focal Fossa v20.04-LTS.
 * [2020-09-09] Added support for PHP v5.6.
 * [2020-09-10] Added support for manually compiling PHP 8 pre-releases.

## v5.0.2: 2020-07-17
 * [2020-07-17] Fixed the .env.stub for Laravel DB engines.
 
## v5.0.1: 2020-05-02
 * [2020-05-02] - Fixed a bug that prevented accessing Postgres DBs via psql.

## v5.0: 2020-04-17
 * Fully automated dockerization via composer.
 * Added the ability to install specific PHP versions + DB creds.
 * Programmatically set the docker network.

## v4.0: 2020-04-12 (Easter 2020)
 * Completely re-engineered the entire project!
 * Refactored the entire build system.
 * Now installs ext-sodium on PHP < 7.2.
 * Now builds every major version of PHP 7 at once.
 * Now upgrades the Ubuntu image to get latest security fixes.
 * Added ext-imagick and ext-sodium.
 * Added unzip and net-tools.

## v3.0: 2020-02-26
 * Majorly refactored the build process to build all of the latest PHP versions 
   at the same time.
 * Added the ability to dynamically pick what PHP version is run via $PHP_VERSION.
 * Added a utility to delete the web images.
 * Fixed the 'Can't locate Term/ReadLine.pm' error.

## v1.4.0: 2020-01-16
 * Upgraded to PHP 7.4.
 * Moved to the standard docker-compose.yml format.
 * PHP v7.4.1
 * Nginx

## v1.3.0: 2019-06-09
 * Upgraded to Ubuntu Bionic (18.04).
 * Upgraded to PHP 7.3.

## v1.2.0: 2018-03-07
* **[2018-02-04]** Upgraded the stack:
  * PHP v7.2.3
  * Nginx v1.10.3 [unchanged]
  * Redis v3.2.11
  * PostgreSQL v9.6.7
  * MariaDB 10.3.4 [unchanged]

* **[2018-02-21]** Added support for multiple nginx vhosts.
* **[2018-02-21]** Added support for SSL certificates and unlimited custom 
                   nginx configuration.
* **[2018-02-21]** Added the bcmath PHP extension.
* **[2018-02-21]** [internal] Created a Makefile for the creation of release files.
* **[2018-02-21]** [internal] Consolidated the common docker files.

## v1.1.0: 2018-02-05

* **[2018-02-05]** The CLI now runs as the current user, NOT as root.
* **[2018-02-05]** The CLI now uses the same Docker net as the main project,
                   so it can communicate with other daemons (redis, psql, etc.).
* **[2018-02-05]** Added a lot of documentation to the project.

## v1.0.0: 2018-02-04

* **[2018-02-04]** Upgraded the stack:
  * PHP v7.2.2
  * Nginx v1.10.3
  * Redis v3.2.6
  * PostgreSQL v9.6.6
  * MariaDB 10.3.4

