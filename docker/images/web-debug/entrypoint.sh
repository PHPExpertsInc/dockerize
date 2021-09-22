#!/usr/bin/env bash

if [ -f "/etc/nginx/custom/nginx.conf" ]; then
  mv /etc/nginx/nginx.conf{,.orig}
  cp /etc/nginx/custom/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f "/etc/nginx/custom/hosts" ]; then
  cat /etc/nginx/custom/hosts >> /etc/hosts
fi

INTERACTIVE=1 /usr/local/bin/entrypoint-php.sh

if [ ! -z "$1" ]; then
    "$@"
    exit
fi

# call the parent images entry point so it can configure PHP etc
supervisord -n
