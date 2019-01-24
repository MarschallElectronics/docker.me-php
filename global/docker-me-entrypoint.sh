#!/bin/bash

#
# [ -n "${SERVER_NAME}" ] -> Variable: String-Länge größer 0
# [ -f /etc/apache2/apache2.conf ] -> prüfen ob Datei vorhanden
# [ -z "$(mount | grep /etc/apache2/apache2.conf)" ] -> prüfen ob Datei reingemappt wurde (Sonst kommt Fehler "Device is busy")
#

set -e

echo "###############################################"
echo "ME: Configure other things"
echo "###############################################"
echo ""

echo "###############################################"
echo "# Globale Vars setzen"
echo "###############################################"

export DOCKER_HOST_IP="$(/sbin/ip route|awk '/default/ { print $3 }')"
export MYHOSTNAME=$(hostname)
export SERVER_NAME
export RELAYHOST
export DOCUMENT_ROOT
export ALIASES
export REMOTE_IP_PROXY
export START_RSYSLOGD
export START_POSTFIX

echo "###############################################"
echo "# Unable to get Full Qualified Servername Workaround"
echo "###############################################"

if [[ -n "${SERVER_NAME}" ]] && [[ -f /etc/apache2/apache2.conf ]] && [[ -z "$(mount | grep /etc/apache2/apache2.conf)" ]]
then
    echo "ServerName "${SERVER_NAME} >> /etc/apache2/apache2.conf
fi

echo "###############################################"
echo "# POSTFIX Config"
echo "###############################################"

if [[ -f /etc/postfix/main.cf ]] && [[ -z "$(mount | grep /etc/postfix/main.cf)" ]]
then
    if [[ -n "${MYHOSTNAME}" ]]
    then
        echo ${MYHOSTNAME} > /etc/mailname
        sed -i 's/'myhostname\ =.*'/'myhostname=${MYHOSTNAME}'/g' /etc/postfix/main.cf
    fi

    if [[ -n "${RELAYHOST}" ]]
    then
        sed -i 's/'relayhost\ =.*'/'relayhost=${RELAYHOST}'/g' /etc/postfix/main.cf
    fi
fi

if [[ -x /etc/init.d/postfix ]] && [[ ${START_POSTFIX} = 'yes' ]]
then
    /etc/init.d/postfix start
fi

echo "###############################################"
echo "# Rsyslogd starten"
echo "###############################################"

if [[ -x /etc/init.d/rsyslog ]] && [[ ${START_RSYSLOGD} = 'yes' ]]
then
    /etc/init.d/rsyslog start
fi

echo "###############################################"
echo "# RemoteIp Config"
echo "###############################################"

if [[ -f /etc/apache2/conf-available/remoteip.conf ]] && [[ -z "$(mount | grep /etc/apache2/conf-available/remoteip.conf)" ]]
then
    if [[ -n "${REMOTE_IP_PROXY}" ]]
    then
        export REMOTE_IP_PROXY=${DOCKER_HOST_IP}
    fi

    if [[ -n "${REMOTE_IP_PROXY}" ]]
    then
        sed -i 's/'RemoteIPTrustedProxy.*'/'RemoteIPTrustedProxy\ ${REMOTE_IP_PROXY}'/g' /etc/apache2/conf-available/remoteip.conf
    fi
fi

echo "###############################################"
echo "# Apache Conf"
echo "###############################################"

if [[ -f /etc/apache2/sites-available/vhost.conf ]] && [[ -z "$(mount | grep /etc/apache2/sites-available/vhost.conf)" ]]
then
    echo "###############################################"
    echo "# SERVER_NAME / Document Root"
    echo "###############################################"

    if [[ -n "${SERVER_NAME}" ]]
    then
        sed -i 's/'ServerName.*'/'ServerName\ ${SERVER_NAME}'/g' /etc/apache2/sites-available/vhost.conf
    fi

    echo "###############################################"
    echo "# Document Root / ATTENTION: Alternate Command delimiter '#' because the DOCUMENT_ROOT hold a PATH witch Slashes"
    echo "###############################################"

    if [[ -n "${DOCUMENT_ROOT}" ]]
    then
        sed -i 's#'DocumentRoot.*'#'DocumentRoot\ ${DOCUMENT_ROOT}'#g' /etc/apache2/sites-available/vhost.conf
    fi

    echo "###############################################"
    echo "# Alias Config"
    echo "###############################################"

    if [[ -n "${ALIASES}" ]]
    then
        sed -i '/Alias/d' /etc/apache2/sites-available/vhost.conf

        SaveIFS=${IFS}
        IFS=';' read -ra aliases <<< "${ALIASES}"
        IFS=${SaveIFS}

        for alias in "${aliases[@]}"; do
            sed -i "/#ALIASES/a Alias $alias" /etc/apache2/sites-available/vhost.conf
        done
    fi
fi

exec "$@"
