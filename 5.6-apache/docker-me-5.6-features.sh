#!/bin/bash

set -e

echo "###############################################"
echo "ME: install-5.6-features"
echo "###############################################"

echo "# PHP-Ext: APCU 4.0.11, Mysql, Mcrypt (Deprecated in 7.2)"
pecl install apcu-4.0.11 \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install mysql mcrypt