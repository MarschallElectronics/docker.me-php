#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.1-features"
echo "###############################################"

echo "# PHP-Ext: Xdebug 2.9.8"
echo "-------------------------------"
pecl install xdebug-2.9.8

echo "# PHP-Ext: xmlrpc (funzt bis PHP 7.4)"
echo "-------------------------------"
docker-php-ext-install xmlrpc && docker-php-ext-enable xmlrpc

echo "# install: php apcu, iconv, mbstring, mcrypt (Deprecated ab 7.2)"
echo "-------------------------------"
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring mcrypt

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
	&& pecl install sqlsrv-5.6.1 pdo_sqlsrv-5.6.1 xdebug