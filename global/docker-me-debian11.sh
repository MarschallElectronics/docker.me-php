#!/bin/bash

set -ex

echo "###############################################"
echo "ME: Install for Debian 11" # @todo
echo "###############################################"

echo "# + install mysqlclient"
echo "-------------------------------"
apt-get install -y mariadb-client-10.5
apt-get install -y mariadb-backup

echo "# + npm"
echo "-------------------------------"
apt-get install -y npm

#echo "# + nodejs" # @todo
#echo "-------------------------------"
#curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - \
#&& apt-get install -y nodejs

echo "# + install Yarn Paketmanager"
echo "-------------------------------"
npm install --global yarn

#
# @todo
# make failed
# compilation terminated.
# make: *** [Makefile:203: apc.lo] Error 1
# ERROR: `make' failed
#
#echo "# install: php apcu"
#echo "-------------------------------"
#printf "\n" | pecl install apc \
#	&& docker-php-ext-enable apcu

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