#!/usr/bin/env bash
#####################################################################
#   The Dockerize PHP Project                                       #
#   https://github.com/PHPExpertsInc/docker-php                     #
#   License: MIT                                                    #
#                                                                   #
# ----------------------------------------------------------------- #
# entrypoint.sh  –  replaces supervisord in phpexperts/web          #
# ----------------------------------------------------------------- #
#                                                                   #
#   Copyright © 2024-2025 PHP Experts, Inc. <sales@phpexperts.pro>  #
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

set -euo pipefail

# ------------------------------------------------------------------
# 1. Start php‑fpm in the background
# ------------------------------------------------------------------
php-fpm &
PHP_PID=$!

# ------------------------------------------------------------------
# 2. Start nginx in the foreground (daemon off)
# ------------------------------------------------------------------
nginx -g 'daemon off;' &
NGINX_PID=$!

# ------------------------------------------------------------------
# 3. Trap signals and kill the children when the container
#    receives SIGTERM or SIGINT.
# ------------------------------------------------------------------
cleanup() {
    echo "Stopping services…"
    kill -TERM "$PHP_PID" "$NGINX_PID" "$BOOTSTRAP_PID" 2>/dev/null
    wait "$PHP_PID" "$NGINX_PID" "$BOOTSTRAP_PID"
    exit 0
}
trap cleanup SIGTERM SIGINT

# ------------------------------------------------------------------
# 4. Wait for the first child to exit; then exit this script
# ------------------------------------------------------------------
wait -n "$PHP_PID" "$NGINX_PID"