#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.2-features"
echo "###############################################"

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y mysql-client

echo "# install: php apcu, iconv, mbstring"
echo "-------------------------------"
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring

echo "# install: php gdlib"
echo "-------------------------------"
docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
  && docker-php-ext-install gd && docker-php-ext-enable gd

echo "# install: sqlsrv pdo_sqlsrv"
echo "-------------------------------"
export ACCEPT_EULA=Y
apt-get update \
	&& curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
	&& locale-gen \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install msodbcsql unixodbc-dev \
	&& docker-php-ext-install pdo pdo_mysql mysqli iconv mbstring \
	&& pecl install sqlsrv-5.6.1 pdo_sqlsrv-5.6.1 xdebug \
	&& docker-php-ext-enable sqlsrv pdo_sqlsrv xdebug \
	&& a2enmod rewrite \
	&& a2dissite 000-default
