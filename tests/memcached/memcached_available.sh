#!/bin/bash

##
## Проверяет что расширение memcached доступно.
##

php -d extension=memcached.so -r 'exit(class_exists("Memcached") ? 0 : 1);'
