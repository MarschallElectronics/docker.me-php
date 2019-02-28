#!/bin/bash

set -e

echo "###############################################"
echo "ME: Install and Configure Packages"
echo "###############################################"

echo "# Update & Upgrade"
echo "-------------------------------"
apt-get update \
    && apt-get upgrade -y

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y locales apt-transport-https nano git net-tools iproute2 mailutils gnupg libxml2-dev mysql-client \
	libbz2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libmcrypt-dev libmemcached-dev \
	libsqlite3-dev libssl-dev libz-dev libz-dev zlib1g-dev libsqlite3-dev zip libxml2-dev rsyslog cron \
	libcurl3-dev libedit-dev libpspell-dev libldap2-dev unixodbc-dev libpq-dev wget libc-client-dev libkrb5-dev

echo "# + Bugfix: libldap (https://bugs.php.net/bug.php?id=49876)"
echo "-------------------------------"
ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/

echo "# + install postfix"
echo "-------------------------------"
echo "postfix postfix/main_mailer_type string Internet site" > /tmp/preseed.txt \
	&& echo "postfix postfix/mailname string docker_web1.garmisch.net" >> /tmp/preseed.txt \
	&& debconf-set-selections /tmp/preseed.txt \
	&& DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y postfix \
	&& rm /tmp/preseed.txt

echo "# + install Language DE"
echo "-------------------------------"
echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen \
	&& locale-gen

echo "# + install PHP-Extensions: GD, Mysql, Mysqli, Soap, Xdebug, ..."
echo "-------------------------------"
docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install gd pdo pdo_mysql mysqli soap pcntl pdo_sqlite zip curl bcmath opcache simplexml xmlrpc xml soap session readline pspell ldap \
	&& pecl install xdebug \
    && docker-php-ext-enable xdebug gd pdo_mysql pcntl pdo_sqlite zip curl bcmath opcache simplexml xmlrpc xml soap session readline pspell ldap \
	&& pear install DB \
	&& pear install DB_Dataobject

echo "# + install Apache Modules: Rewrite, Remoteip, SSL, Headers, ... "
echo "-------------------------------"
a2enmod rewrite \
    && a2enmod ssl \
    && a2enmod remoteip \
    && a2enmod headers \
    && echo "RemoteIPHeader X-Forwarded-For" > /etc/apache2/conf-available/remoteip.conf \
    && echo "RemoteIPTrustedProxy 127.0.0.1" >> /etc/apache2/conf-available/remoteip.conf \
	&& a2enconf remoteip

echo "# + install PHP Composer"
echo "-------------------------------"
php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
    && php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === trim(file_get_contents('https://composer.github.io/installer.sig'))) { echo 'PHP-Composer-Installer verified'; } else { echo 'PHP-Composer-Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;" \
    && php /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer \
    && rm /tmp/composer-setup.php

echo "# + install NodeJS"
echo "-------------------------------"
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs

echo "# + install Yarn Paketmanager"
echo "-------------------------------"
npm install --global yarn

echo "# + install Apache Vhost"
echo "-------------------------------"
a2dissite 000-default \
	&& a2ensite vhost.conf

echo "# Cleanup"
echo "-------------------------------"
apt-get autoremove -y \
    && apt-get clean all \
    && rm -rvf /var/lib/apt/lists/* \
    && rm -rvf /usr/share/doc /usr/share/man \
    && rm -rvf /usr/src/php
