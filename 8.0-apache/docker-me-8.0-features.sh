#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.4-features"
echo "###############################################"

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y mariadb-client-10.3

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

# @todo
echo "# install: imagick" #
echo "-------------------------------"
#apt-get -y install libmagickwand-dev --no-install-recommends \
#  && printf "\n" | pecl install imagick \
#  && docker-php-ext-enable imagick \
#  && rm -r /var/lib/apt/lists/*

# workaround mit warnings
mkdir -p /usr/src/php/ext/imagick \
  && curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1 \
  && docker-php-ext-install imagick

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