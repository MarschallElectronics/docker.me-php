#!/bin/bash

set -e



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






exec "$@"


