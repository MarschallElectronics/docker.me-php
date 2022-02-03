#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.4-features"
echo "###############################################"

echo "# PHP-Ext: Xdebug 2.9.8"
echo "-------------------------------"
pecl install xdebug-2.9.8

echo "# install: imagick" #
echo "-------------------------------"
apt-get -y install libmagickwand-dev --no-install-recommends \
  && printf "\n" | pecl install imagick \
  && docker-php-ext-enable imagick \
  && rm -r /var/lib/apt/lists/*

echo "# install: sqlsrv pdo_sqlsrv"
echo "-------------------------------"
export ACCEPT_EULA=Y
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev mssql-tools \
	&& odbcinst -j \
	&& pecl install sqlsrv-5.10.0 \
  && docker-php-ext-enable sqlsrv \
	&& pecl install pdo_sqlsrv-5.10.0 \
	&& docker-php-ext-enable pdo_sqlsrv \
	&& ln -s /opt/mssql-tools/bin/sqlcmd /usr/local/bin/sqlcmd
