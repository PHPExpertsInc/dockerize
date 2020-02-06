#!/usr/bin/env bash

if [ -f "/etc/nginx/custom/nginx.conf" ]; then
  mv /etc/nginx/nginx.conf{,.orig}
  cp /etc/nginx/custom/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f "/etc/nginx/custom/hosts" ]; then
  cat /etc/nginx/custom/hosts >> /etc/hosts
fi

# call the parent images entry point so it can configure PHP etc
supervisord -n
