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

