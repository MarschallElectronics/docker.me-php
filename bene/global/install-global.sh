#!/bin/bash

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
	&& docker-php-ext-install gd pdo pdo_mysql mysqli \
	&& a2enmod rewrite \
	&& a2enmod remoteip \
	&& pear install DB \
	&& pear install DB_Dataobject \
	&& a2enconf remoteip \
	&& a2dissite 000-default \
	&& a2ensite vhost.conf

echo "###############################################"
echo "ME: Configure other things"
echo "###############################################"

##################################################################################################################
# Globale Vars
##################################################################################################################

export DOCKER_HOST_IP="$(/sbin/ip route|awk '/default/ { print $3 }')"
export MYHOSTNAME=$(hostname)
export SERVER_NAME
export RELAYHOST
export DOCUMENT_ROOT
export ALIASES
export REMOTE_IP_PROXY

##################################################################################################################
# Unable to get Full Qualified Servername Workaround
##################################################################################################################

if [ "X" != "X${SERVER_NAME}" ]
then
    touch /etc/apache2/apache2.conf
    echo "ServerName "${SERVER_NAME} >> /etc/apache2/apache2.conf
fi

##################################################################################################################
# POSTFIX Config
##################################################################################################################

if [ "X" != "X${MYHOSTNAME}" ]
then
    touch /etc/postfix/main.cf
    echo ${MYHOSTNAME} > /etc/mailname
    sed -i 's/'myhostname\ =.*'/'myhostname=${MYHOSTNAME}'/g' /etc/postfix/main.cf
fi

if [ "X" != "X${RELAYHOST}" ]
then
    touch /etc/postfix/main.cf
    sed -i 's/'relayhost\ =.*'/'relayhost=${RELAYHOST}'/g' /etc/postfix/main.cf
fi

if [ -x /etc/init.d/postfix ]
then
    /etc/init.d/postfix start
fi

##################################################################################################################
# RemoteIp Config
##################################################################################################################

if [ "X" = "X${REMOTE_IP_PROXY}" ]
then
    export REMOTE_IP_PROXY=${DOCKER_HOST_IP}
fi

if [ "X" != "X${REMOTE_IP_PROXY}" ]
then
    touch /etc/apache2/conf-available/remoteip.conf
    sed -i 's/'RemoteIPTrustedProxy.*'/'RemoteIPTrustedProxy\ ${REMOTE_IP_PROXY}'/g' /etc/apache2/conf-available/remoteip.conf
fi

##################################################################################################################
# Apache Conf
# Document Root
##################################################################################################################

if [ "X" != "X${SERVER_NAME}" ]
then
        touch /etc/apache2/sites-available/vhost.conf
        sed -i 's/'ServerName.*'/'ServerName\ ${SERVER_NAME}'/g' /etc/apache2/sites-available/vhost.conf
fi

# Document Root
# ATTENTION: Alternate Command delimiter '#' because the "$DOCUMENT_ROOT" hold a PATH witch Slashes
if [ "X" != "X${DOCUMENT_ROOT}" ]
then
        touch /etc/apache2/sites-available/vhost.conf
        sed -i 's#'DocumentRoot.*'#'DocumentRoot\ ${DOCUMENT_ROOT}'#g' /etc/apache2/sites-available/vhost.conf
fi

##################################################################################################################
# Alias Config
##################################################################################################################

if [ "X" != "X${ALIASES}" ]
then
    touch /etc/apache2/sites-available/vhost.conf
	sed -i '/Alias/d' /etc/apache2/sites-available/vhost.conf

	SaveIFS=${IFS}
	IFS=';' read -ra aliases <<< "${ALIASES}"
	IFS=${SaveIFS}

	for alias in "${aliases[@]}"; do
			sed -i "/#ALIASES/a Alias $alias" /etc/apache2/sites-available/vhost.conf
	done
fi
