#!/bin/bash

##################################################################################################################
# Globale Host IP
export DOCKER_HOST_IP="$(/sbin/ip route|awk '/default/ { print $3 }')"

##################################################################################################################
# Unable to get Full Qualified Servername Workaround
echo "ServerName "$SERVER_NAME >> /etc/apache2/apache2.conf

##################################################################################################################
# SSMTP Config
sed -i 's/'mailhub=.*'/'mailhub=$SSMTP_MAILHUB'/g' /etc/ssmtp/ssmtp.conf
sed -i 's/'hostname=.*'/'hostname=$SERVER_NAME'/g' /etc/ssmtp/ssmtp.conf

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
