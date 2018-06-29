#!/bin/bash

echo "###############################################"
echo "ME: Default ENVIRONMENT-Variablen setzen"
echo "###############################################"

# Default Server ENV
export SERVER_NAME=me-base.garmisch.net

# SMTP ENV
export RELAYHOST=mx2.garmisch.net

# Apache ENV
export APACHE_DOC_ROOT=/var/www/html
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
export APACHE_RUN_DIR=/var/run/apache2
export APACHE_LOG_DIR=/var/log/apache2
export APACHE_LOCK_DIR=/var/lock/apache2
export APACHE_PID_FILE=/var/run/apache2.pid

echo "###############################################"
echo "ME: Install and Configure Packages"
echo "###############################################"

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
	&& docker-php-ext-install gd pdo pdo_mysql mysqli iconv mbstring \
	&& a2enmod rewrite \
	&& a2enmod remoteip \
	&& pecl install apcu-4.0.11 \
	&& echo "docker-php-ext-enable apcu" \
	&& docker-php-ext-enable apcu \
	&& pear install DB \
	&& pear install DB_Dataobject \
	&& a2enconf remoteip \
	&& a2dissite 000-default \
	&& a2ensite vhost.conf

echo "###############################################"
echo "ME: Configure other things"
echo "###############################################"

##################################################################################################################
# Globale Host IP
export DOCKER_HOST_IP="$(/sbin/ip route|awk '/default/ { print $3 }')"
export MYHOSTNAME=$(hostname)

##################################################################################################################
# Unable to get Full Qualified Servername Workaround
echo "ServerName "$SERVER_NAME >> /etc/apache2/apache2.conf

##################################################################################################################
# POSTFIX Config
echo $MYHOSTNAME > /etc/mailname
sed -i 's/'relayhost\ =.*'/'relayhost=$RELAYHOST'/g' /etc/postfix/main.cf
sed -i 's/'myhostname\ =.*'/'myhostname=$MYHOSTNAME'/g' /etc/postfix/main.cf

/etc/init.d/postfix start

##################################################################################################################
# RemoteIp Config
if [ -z "$REMOTE_IP_PROXY" ]
then
	export REMOTE_IP_PROXY=$DOCKER_HOST_IP
fi
sed -i 's/'RemoteIPTrustedProxy.*'/'RemoteIPTrustedProxy\ $REMOTE_IP_PROXY'/g' /etc/apache2/conf-available/remoteip.conf

##################################################################################################################
# Apache Conf
# Document Root
sed -i 's/'ServerName.*'/'ServerName\ $SERVER_NAME'/g' /etc/apache2/sites-available/vhost.conf

# Document Root
# ATTENTION: Alternate Command delimiter '#' because the "$DOCUMENT_ROOT" hold a PATH witch Slashes
sed -i 's#'DocumentRoot.*'#'DocumentRoot\ $DOCUMENT_ROOT'#g' /etc/apache2/sites-available/vhost.conf

# Alias Config
sed -i '/Alias/d' /etc/apache2/sites-available/vhost.conf

SaveIFS=$IFS
IFS=';' read -ra aliases <<< "$ALIASES"
IFS=$SaveIFS

for alias in "${aliases[@]}"; do
	sed -i "/#ALIASES/a Alias $alias"  /etc/apache2/sites-available/vhost.conf
done