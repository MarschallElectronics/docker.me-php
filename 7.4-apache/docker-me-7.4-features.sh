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

	# @todo install von mbstring funzt nicht
	# docker-php-ext-install mbstring

echo "# install: sqlsrv pdo_sqlsrv"
echo "-------------------------------"
export ACCEPT_EULA=Y
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev \
	&& odbcinst -j

	# @todo install von sqlsrv funzt nicht
	#&& pecl install sqlsrv \
	#&& docker-php-ext-enable sqlsrv \
	#&& pecl install pdo_sqlsrv \
	#&& docker-php-ext-enable pdo_sqlsrv