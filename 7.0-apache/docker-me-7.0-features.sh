#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.0-features"
echo "###############################################"

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y mysql-client

echo "# PHP-Ext: APCU, iconv, mbstring, Mcrypt (Deprecated in 7.2)"
echo "-------------------------------"
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring mcrypt

echo "# install: php gdlib"
echo "-------------------------------"
docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
  && docker-php-ext-install gd && docker-php-ext-enable gd