#!/usr/bin/env bash

# this has to be done at runtime, because the /etc/hosts file is replaced at startup by Docker
echo '127.0.0.1 api.myproject.local' >> /etc/hosts

# call the parent images entry point so it can configure PHP etc
/usr/local/bin/entrypoint-php.sh supervisord -n
