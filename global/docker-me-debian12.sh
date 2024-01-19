#!/bin/bash

set -ex

echo "###############################################"
echo "ME: Install for Debian 11" # @todo
echo "###############################################"

echo "# + install mysqlclient"
echo "-------------------------------"
apt-get install -y mariadb-client-core
apt-get install -y mariadb-backup

echo "# + npm"
echo "-------------------------------"
apt-get install -y npm

echo "# + install Yarn Paketmanager"
echo "-------------------------------"
npm install --global yarn

echo "# install: php apcu"
echo "-------------------------------"
pecl install apcu

echo "# install: php iconv"
echo "-------------------------------"
docker-php-ext-install iconv

echo "# install: php gdlib"
echo "-------------------------------"
docker-php-ext-configure gd --with-freetype --with-jpeg --with-xpm \
  && docker-php-ext-install gd && docker-php-ext-enable gd

echo "# install: gmp" #
echo "-------------------------------"
apt-get install -y libgmp-dev \
  && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
  && docker-php-ext-install -j$(nproc) gmp

echo "# install: php: imap" #
echo "-------------------------------"
docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install -j$(nproc) imap
