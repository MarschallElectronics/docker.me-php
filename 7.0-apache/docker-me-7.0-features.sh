#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.0-features"
echo "###############################################"

echo "# PHP-Ext: Xdebug 2.9.8"
echo "-------------------------------"
pecl install xdebug-2.9.8

echo "# PHP-Ext: xmlrpc (funzt bis PHP 7.4)"
echo "-------------------------------"
docker-php-ext-install xmlrpc && docker-php-ext-enable xmlrpc

echo "# PHP-Ext: APCU"
echo "-------------------------------"
pecl install apcu \
&& docker-php-ext-enable apcu

echo "# PHP-Ext: iconv, mbstring, Mcrypt (Deprecated in 7.2)"
echo "-------------------------------"
docker-php-ext-install iconv mbstring mcrypt