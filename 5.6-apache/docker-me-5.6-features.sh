#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-5.6-features"
echo "###############################################"

echo "# PHP-Ext: Xdebug 2.9.8"
echo "-------------------------------"
pecl install xdebug-2.9.8

echo "# PHP-Ext: xmlrpc (funzt bis PHP 7.4)"
echo "-------------------------------"
docker-php-ext-install xmlrpc && docker-php-ext-enable xmlrpc

echo "# PHP-Ext: APCU 4.0.11, Mysql, Mcrypt (Deprecated in 7.2)"
echo "-------------------------------"
pecl install apcu-4.0.11 \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install mysql mcrypt

echo "# Install Xdebug für PHP5"
curl -fsSL 'https://xdebug.org/files/xdebug-2.4.0.tgz' -o xdebug.tar.gz \
    && mkdir -p xdebug \
    && tar -xf xdebug.tar.gz -C xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && ( \
    cd xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(nproc) \
    && make install \
    ) \
    && rm -r xdebug \
    && docker-php-ext-enable xdebug
