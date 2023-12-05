#!/bin/bash

clear
for VERSION in 5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3
do
    PHP_VERSION=$VERSION php --version
done
