#!/bin/bash

docker images | grep web | awk '{print $3}' | xargs docker rmi --force

