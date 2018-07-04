#!/bin/bash

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
#    echo "$alias"
    sed -i "/#ALIASES/a Alias $alias"  /etc/apache2/sites-available/vhost.conf
done

apache2 -D FOREGROUND
