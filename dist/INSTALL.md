Includes: 
 * PHP v7.2.2, built on 1 Feb 2018
 * Nginx v1.10.3
 * Redis v3.2.6
 * PostgreSQL v9.6.6
 * MariaDB 10.3.4

# Installation

* Watch the [**Installation HOWTO video**](https://vimeo.com/254179137).

1. Pick the database you want and copy the directory's files to 
the root directory of your project.

        cp -rvf postgres/* /path/to/your/project

2. Ensure that /path/to/your/project/bin is *first* in your PATH:

        echo 'PATH=./bin:$PATH' >> ~/.bashrc
        source ~/.bashrc

3. Create and run the docker containers:

        cd /path/to/your/project
        containers up -d

4. Confirm everything is running:

        # View the logs
        containers logs -ft
        # See the docker status
        docker ps
