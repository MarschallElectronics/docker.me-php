#!/bin/bash

set -e

echo "###############################################"
echo "ME: install-7.1-features"
echo "###############################################"

echo "# install: php apcu, iconv, mbstring, mcrypt (Deprecated ab 7.2)"
echo "-------------------------------"
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring mcrypt

echo "# install: sqlsrv pdo_sqlsrv"
echo "-------------------------------"
export ACCEPT_EULA=Y
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev \
	&& pecl install sqlsrv pdo_sqlsrv \
	&& docker-php-ext-enable sqlsrv pdo_sqlsrv
