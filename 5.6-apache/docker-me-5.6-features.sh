#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-5.6-features"
echo "###############################################"

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y mysql-client

echo "# Systemd & rc.local"
echo "-------------------------------"
apt-get install -y systemd \
  && systemctl enable rc-local

echo "# PHP-Ext: APCU 4.0.11, Mysql, Mcrypt (Deprecated in 7.2)"
echo "-------------------------------"
pecl install apcu-4.0.11 \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install mysql mcrypt

echo "# install: php gdlib"
echo "-------------------------------"
docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
  && docker-php-ext-install gd && docker-php-ext-enable gd

echo "# Install Xdebug für PHP5"
echo "-------------------------------"
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
