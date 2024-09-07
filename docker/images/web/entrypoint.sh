#!/usr/bin/env bash
#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
#   Copyright © 2024 PHP Experts, Inc. <sales@phpexperts.pro>       #
#       Author: Theodore R. Smith <theodore@phpexperts.pro>         #
#      PGP Sig: 4BF826131C3487ACD28F2AD8EB24A91DD6125690            #
#####################################################################

if [ -f "/etc/nginx/custom/nginx.conf" ]; then
  mv /etc/nginx/nginx.conf{,.orig}
  cp /etc/nginx/custom/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f "/etc/nginx/custom/hosts" ]; then
  cat /etc/nginx/custom/hosts >> /etc/hosts
fi

if [ ! -z "$1" ]; then
    "$@"
    exit
fi

# call the parent images entry point so it can configure PHP etc
supervisord -n
