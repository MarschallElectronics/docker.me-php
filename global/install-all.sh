#!/bin/bash

apt-get update \
	&& apt-get install -y --no-install-recommends locales apt-transport-https nano git net-tools iproute2 mailutils gnupg \
	&& apt-get install -y libbz2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libmcrypt-dev libmemcached-dev \
	&& echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt \
	&& echo "postfix postfix/mailname string docker_web1.garmisch.net" >> preseed.txt \
	&& debconf-set-selections preseed.txt \
	&& DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y postfix \
	&& apt-get upgrade -y \
	&& echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen \
	&& locale-gen \
	&& apt-get update \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install mysql gd pdo pdo_mysql mysqli iconv mbstring \
	&& a2enmod rewrite \
	&& a2enmod remoteip \
	&& pecl install apcu-4.0.11 \
	&& docker-php-ext-enable apcu \
	&& pear install DB \
	&& pear install DB_Dataobject \
	&& a2enconf remoteip \
	&& a2dissite 000-default \
	&& a2ensite vhost.conf \
	&& chmod +x /usr/local/bin/start-container.sh