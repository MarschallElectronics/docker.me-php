#!/bin/bash

set -ex

echo "###############################################"
echo "ME: Install for Debian 10"
echo "###############################################"

echo "# + install mysqlclient"
echo "-------------------------------"
apt-get install -y mariadb-client-10.3

echo "# + nodejs + npm"
echo "-------------------------------"
su -c 'curl -sL https://deb.nodesource.com/setup_16.x | bash -' \
  && apt-get install -y nodejs npm

echo "# + install Yarn Paketmanager"
echo "-------------------------------"
npm install --global yarn

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

echo "# install: gmp" #
echo "-------------------------------"
apt-get install -y libgmp-dev \
  && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
  && docker-php-ext-install -j$(nproc) gmp

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
	&& docker-php-ext-enable pdo_sqlsrv \
	&& ln -s /opt/mssql-tools/bin/sqlcmd /usr/local/bin/sqlcmd