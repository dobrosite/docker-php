#!/bin/bash

##
## Проверяет обход ошибки 48614.
## @link https://bugs.php.net/bug.php?id=48614
##

php -d extension=pdo_sqlite.so -r 'new PDO("sqlite::memory:");'
