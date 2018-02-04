#!/bin/sh

#
# Ensures that the project's network exists.
#
# The purpose of this script is to allow Docker scripts that need a network to
# leverage this script to ensure that the network exists before attempting to
# connect to it.
#

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

. "${ROOT}"/docker/lib/env.sh

NETWORK="${PROJECT_NAME}_default"

# Ensure Docker network exists (needed to run composer in php container)
if [ `docker network ls | grep "${NETWORK}" | wc -l | awk '{print $1}'` == 0 ]; then
    docker network create "${NETWORK}"
fi
