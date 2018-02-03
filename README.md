# Docker image for PHP

A [Docker](https://www.docker.com) image for the [PHP](https://secure.php.net/) Command Line scripting language.

To use the container with a project, do the following:

  * Copy the bin directory into your project.

  * Ensure that your profile PATH includes `./bin` and that it takes priority over any other directory that may include a php executable:

        PATH=./bin:$PATH

Now whenever you are in your project's directory, you can simply execute `php` as you would with a typical composer installation, and the command will execute in the container instead:

    php -r 'phpinfo();'

# User ID control

It is possible to control what UID the initial process (usually PHP) and/or PHP-FPM processes run as. The `bin/php` file already does this for the initial process.

This is important if you are mounting a volumes into the container, as the the UID of the initial process or PHP-FPM will likely need to match the volume to be able to read and/or write to it.

Note: You should _NOT_ try to set the UID using Dockers -u or --user option, as this does not ensure that the user actually exists (entry in `/etc/passwd` home directory etc).

## Initial process UID

To set the UID for the initial process, you should set a `LOCAL_USER_ID` environmental variable on the container. e.g:

    docker run -e LOCAL_USER_ID=1000 chekote/php:5.6.30-a php -v

## PHP-FPM process UID

To set the UID for the PHP-FPM process, you should set the `PHP_FPM_USER_ID` environmental variable on the container. e.g:

    docker run -e PHP_FPM_USER_ID=1000 chekote/php:5.6.30-a php-fpm5.6

# php.ini directives

You can modify certain php.ini directives by setting environmental variables within the container. The following is a list of environmental variables and the php.ini directives that they correspond to:

| environmental variable  | php.ini directives                                                                       |
|-------------------------|---------------------------------------------------------------------------------------|
| `PHP_POST_MAX_SIZE`       | [`post_max_size`](http://php.net/manual/en/ini.core.php#ini.post-max-size)              |
| `PHP_UPLOAD_MAX_FILESIZE` | [`upload_max_filesize`](http://php.net/manual/en/ini.core.php#ini.upload-max-filesize)  |

e.g. the following will start a PHP container with the `post_max_size` to 30 Megabytes:

`docker run -e PHP_POST_MAX_SIZE=30M chekote/php:7`

# Distribution

Docker Hub : https://hub.docker.com/r/chekote/php/
