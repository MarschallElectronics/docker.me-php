#!/bin/bash

echo "###############################################"
echo "ME: Install and Configure Packages"
echo "###############################################"

# Update & Upgrade
apt-get update \
    && apt-get upgrade -y

# diverse Apps
apt-get install -y --no-install-recommends locales apt-transport-https nano git net-tools iproute2 mailutils gnupg \
	&& apt-get install -y libbz2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libmcrypt-dev libmemcached-dev \

# postfix
echo "postfix postfix/main_mailer_type string Internet site" > /tmp/preseed.txt \
	&& echo "postfix postfix/mailname string docker_web1.garmisch.net" >> /tmp/preseed.txt \
	&& debconf-set-selections /tmp/preseed.txt \
	&& DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y postfix

# Language
echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen \
	&& locale-gen

# PHP-Extensions
docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install gd pdo pdo_mysql mysqli \
	&& pear install DB \
	&& pear install DB_Dataobject \

# Aapche Module
a2enmod rewrite \
    && a2enmod remoteip \
    && echo "RemoteIPHeader X-Forwarded-For" > /etc/apache2/conf-available/remoteip.conf \
    && echo "RemoteIPTrustedProxy 127.0.0.1" >> /etc/apache2/conf-available/remoteip.conf \
	&& a2enconf remoteip

# Apache Vhost
a2dissite 000-default \
	&& a2ensite vhost.conf


