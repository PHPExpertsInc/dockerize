# Frequently Asked Questions

### What is included in this project?

 * PHP v7.3.0, built on 17 December 2018
 * Nginx v1.10.3
 * Redis v3.2.6
 * PostgreSQL v9.6.6
 * MariaDB 10.3.4
 
 ## What are the advantages over other dockerized PHP projects?
 
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

With every other dockerized PHP platformer I am aware of, you are on your own 
when it comes to setting up these client utilities.

### What does this provide that Laravel Homestead does not?

Laravel Homestead uses Vagrant and full virtual machines. This is *way* overkill when
you want a dockerized PHP app running on native Linux dev boxes and servers, like I
do.

For instance, to get this setup as a server on [**DigitalOcean's Docker app
server**](https://www.digitalocean.com/products/one-click-apps/docker/?refcode=724f89bd9417),
I simply do this:

    git clone git@github.com:my/repo.git
    cd my_repo 
    bin/containers up -d

*DONE!* And it runs at almost-native speeds and doesn't have nearly the overhead of
VirtualBox. Plus, setup takes 2 minutes vs the 30+ minutes it takes vagrant to build
the VM.

### Is this ready for production?

This project is run on several production sites, including a large ecommerce site.

Use it yourself! Get a [Digital Ocean Docker App
Droplet](https://www.digitalocean.com/products/one-click-apps/docker/?refcode=724f89bd9417)
for $5, clone your repo on the droplet, and then just run `containers up`. There! You
have a live site in 5 minutes!

### Do you really have time to maintain this?

Since we're porting all of my company's production sites to this, and several clients
already have it running in production, yes. I'm committed to actively maintaining
this project for the long-term future. As a corporate policy, we strive to keep
things as leading-edge as possible, so this project will always be relatively
bleeding-but-stable-edge.

### Why not just use docker-compose?

This project does use docker-compose. Think of `bin/containers` as a CLI UI around
docker-compose in way that lets you handle multiple server environments very easily.

### Why fork from Chekote/docker-php

This project started as a collaborative effort to improve that project, which I
utilize every day. This project's `7` branch is a rolling fork of that project,
mainly so I can contribute upstream.

-----

[PHP Experts, Inc.](https://www.phpexperts.pro/), is my consultation company. It's a
small company of a half dozen highly skilled Full Stack PHP devs, including myself,
whom I place at 1099 positions at other corporations. We fill both long-term
positions and, for crazy devs like me, short-term. If you ever wanted to work on a
different project/company every few months or even weeks, anywhere in the continental
U.S., Europe, or South East Asia, it's fantastic.  

Since 2015, I have set up branches in Las Vegas, Houston, the UK, Dublin, Costa Rica,
Colombia, India, and the Philippines. If someone has a work auth in any of those
places, we can place you almost anywhere you want. I travel 50% of the time out of
choice. All over the world.

Did I mention that you get paid in the cryptocurrency of your choice?

Starting in mid-2017, we've begun a pivot towards a NodeJS and
cryptocurrency-specific corporation. We are making some REALLY exciting things, like
our dockerized PHP-based cryptocurrency payment gateway we'll be releasing in 2Q
2018.

