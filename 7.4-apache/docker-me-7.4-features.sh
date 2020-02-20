#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.4-features"
echo "###############################################"

echo "# + install diverse Apps"
echo "-------------------------------"
# @todo install von mysql-client funzt nicht
#apt-get install -y mysql-client

echo "# install: php apcu, iconv, mbstring"
echo "-------------------------------"
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv

echo "# install: php gdlib"
echo "-------------------------------"
docker-php-ext-configure gd --with-freetype --with-jpeg --with-xpm \
  && docker-php-ext-install gd && docker-php-ext-enable gd

echo "# install: mbstring : benötigt libonig-dev (gibts nicht über apt-get)"
echo "-------------------------------"
wget -P /tmp/ http://ftp.de.debian.org/debian/pool/main/libo/libonig/libonig-dev_6.9.1-1_amd64.deb \
  && dpkg -i /tmp/libonig-dev_6.9.1-1_amd64.deb \
  && docker-php-ext-install mbstring

echo "# install: sqlsrv pdo_sqlsrv"
echo "-------------------------------"
export ACCEPT_EULA=Y
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev mssql-tools \
	&& odbcinst -j \
	&& pecl install sqlsrv \
  && docker-php-ext-enable sqlsrv \
	&& pecl install pdo_sqlsrv \
	&& docker-php-ext-enable pdo_sqlsrv