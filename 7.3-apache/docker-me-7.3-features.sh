#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.3-features"
echo "###############################################"

echo "# install: php apcu, iconv, mbstring"
echo "-------------------------------"
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring

echo "# install: gmp" #
echo "-------------------------------"
apt-get install -y libgmp-dev \
  && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
  && docker-php-ext-install -j$(nproc) gmp

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
	&& curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev mssql-tools \
	&& pecl install sqlsrv-5.9.0 pdo_sqlsrv-5.9.0
