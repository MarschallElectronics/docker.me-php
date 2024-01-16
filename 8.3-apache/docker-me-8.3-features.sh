#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-8.3-features"
echo "###############################################"

echo "# PHP-Ext: Xdebug 3"
echo "-------------------------------"
pecl install xdebug-3.3.1

# @todo: funzt nicht: Error bei "pecl install imagick":
#  make: *** [Makefile:196: /tmp/pear/temp/imagick/Imagick_arginfo.h] Error 1
#  ERROR: `make INSTALL_ROOT="/tmp/pear/temp/pear-build-defaultuserTmSN91/install-imagick-3.7.0" install' failed
#echo "# install: imagick" #
#echo "-------------------------------"
#apt-get -y install libmagickwand-dev --no-install-recommends \
#  && printf "\n" | pecl install imagick \
#  && docker-php-ext-enable imagick \
#  && rm -r /var/lib/apt/lists/*

echo "# install: sqlsrv pdo_sqlsrv"
echo "-------------------------------"
export ACCEPT_EULA=Y \
  && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
	&& curl https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev mssql-tools \
	&& odbcinst -j \
	&& pecl install sqlsrv-5.11.1 \
  && docker-php-ext-enable sqlsrv \
	&& pecl install pdo_sqlsrv-5.11.1 \
	&& docker-php-ext-enable pdo_sqlsrv \
	&& ln -s /opt/mssql-tools/bin/sqlcmd /usr/local/bin/sqlcmd
