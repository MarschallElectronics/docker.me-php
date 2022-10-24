#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-8.0-features"
echo "###############################################"

echo "# PHP-Ext: Xdebug 3.1.3"
echo "-------------------------------"
pecl install xdebug-3.1.3

# @todo
echo "# install: imagick"
echo "-------------------------------"
#apt-get -y install libmagickwand-dev --no-install-recommends \
#  && printf "\n" | pecl install imagick \
#  && docker-php-ext-enable imagick \
#  && rm -r /var/lib/apt/lists/*

# workaround mit warnings
apt-get -y install libmagickwand-dev --no-install-recommends \
  && mkdir -p /usr/src/php/ext/imagick \
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
	&& pecl install sqlsrv-5.10.0 \
  && docker-php-ext-enable sqlsrv \
	&& pecl install pdo_sqlsrv-5.10.0 \
	&& docker-php-ext-enable pdo_sqlsrv \
	&& ln -s /opt/mssql-tools/bin/sqlcmd /usr/local/bin/sqlcmd
