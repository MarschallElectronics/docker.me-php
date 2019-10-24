#!/bin/bash

#
# [ -n "${SERVER_NAME}" ] -> -n ZEICHENKETTE : Die LÃƒÂ¤nge von ZEICHENKETTE ist ungleich Null
# [ -f /etc/apache2/apache2.conf ] -> prÃƒÂ¼fen ob Datei vorhanden
# [ -z "$(mount | grep /etc/apache2/apache2.conf)" ] -> prÃƒÂ¼fen ob Datei reingemappt wurde (Sonst kommt Fehler "Device is busy")
#

set -e

echo "###############################################"
echo "ME: Configure other things"
echo "###############################################"
echo ""

echo "###############################################"
echo "# Globale Vars setzen"
echo "###############################################"

set -x

export DOCKER_HOST_IP="$(/sbin/ip route | awk '/default/ { print $3 }')"
export MYHOSTNAME=$(hostname)
export SERVER_NAME
export POSTFIX_MYHOSTNAME
export RELAYHOST
export DOCUMENT_ROOT
export ALIASES
export REMOTE_IP_PROXY
export START_RSYSLOGD
export START_CROND
export START_POSTFIX
export DEFAULT_PHPINI

set +x
echo "###############################################"
echo "# Unable to get Full Qualified Servername Workaround"
echo "###############################################"
set -x

if [[ -n "${SERVER_NAME}" ]] && [[ -f /etc/apache2/apache2.conf ]] && [[ -z "$(mount | grep /etc/apache2/apache2.conf)" ]]; then
  echo "ServerName "${SERVER_NAME} >>/etc/apache2/apache2.conf
fi

set +x
echo "###############################################"
echo "# Welche PHP.INI (production/development) #"
echo "###############################################"
set -x

if [[ -n "${PHPINI}" ]] && [[ ${DEFAULT_PHPINI} == 'development' ]]; then
  cp -p "${PHP_INI_DIR}/php.ini-development" "${PHP_INI_DIR}/php.ini"
else
  cp -p "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"
fi

set +x
echo "###############################################"
echo "# POSTFIX Config"
echo "###############################################"
set -x

if [[ -f /etc/postfix/main.cf ]] && [[ -z "$(mount | grep /etc/postfix/main.cf)" ]]; then
  # Wenn Hostname vorhanden dann als Hostname fÃƒÂ¼r Postfix nehmen
  # Problem: manchmal wird nicht der komplette Hostname (FQDN) verwendet. Es werden dann keine Mails versendet :-(.
  if [[ -n "${MYHOSTNAME}" ]]; then
    echo ${MYHOSTNAME} >/etc/mailname
    sed -i "s/myhostname.*=.*/myhostname = ${MYHOSTNAME}/g" /etc/postfix/main.cf
  fi

  # Wenn Postfix-Hostname gesetzt wurde, dann den verwenden
  if [[ -n "${POSTFIX_MYHOSTNAME}" ]]; then
    echo ${POSTFIX_MYHOSTNAME} >/etc/mailname
    sed -i "s/myhostname.*=.*/myhostname = ${POSTFIX_MYHOSTNAME}/g" /etc/postfix/main.cf
  fi

  # Relayhost
  if [[ -n "${RELAYHOST}" ]]; then
    sed -i "s/relayhost.*=.*/relayhost = ${RELAYHOST}/g" /etc/postfix/main.cf
  fi
fi

if [[ -x /etc/init.d/postfix ]] && [[ ${START_POSTFIX} == 'yes' ]]; then
  /etc/init.d/postfix start
fi

set +x
echo "###############################################"
echo "# Rsyslogd starten"
echo "###############################################"
set -x

if [[ -x /etc/init.d/rsyslog ]] && [[ ${START_RSYSLOGD} == 'yes' ]]; then
  /etc/init.d/rsyslog start
fi

set +x
echo "###############################################"
echo "# Crond starten"
echo "###############################################"
set -x

if [[ -x /etc/init.d/cron ]] && [[ ${START_CROND} == 'yes' ]]; then
  /etc/init.d/cron start
fi

set +x
echo "###############################################"
echo "# RemoteIp Config"
echo "###############################################"
set -x

if [[ -f /etc/apache2/conf-available/remoteip.conf ]] && [[ -z "$(mount | grep /etc/apache2/conf-available/remoteip.conf)" ]]; then
  if [[ -n "${REMOTE_IP_PROXY}" ]]; then
    export REMOTE_IP_PROXY=${DOCKER_HOST_IP}
  fi

  if [[ -n "${REMOTE_IP_PROXY}" ]]; then
    sed -i "s/RemoteIPTrustedProxy.*/RemoteIPTrustedProxy ${REMOTE_IP_PROXY}/g" /etc/apache2/conf-available/remoteip.conf
  fi
fi

set +x
echo "###############################################"
echo "# Apache Conf"
echo "###############################################"
set -x

if [[ -f /etc/apache2/sites-available/vhost.conf ]] && [[ -z "$(mount | grep /etc/apache2/sites-available/vhost.conf)" ]]; then
  set +x
  echo "###############################################"
  echo "# SERVER_NAME / Document Root"
  echo "###############################################"
  set -x

  if [[ -n "${SERVER_NAME}" ]]; then
    sed -i "s/ServerName.*/ServerName ${SERVER_NAME}/g" /etc/apache2/sites-available/vhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# Document Root / ATTENTION: Alternate Command delimiter '#' because the DOCUMENT_ROOT hold a PATH witch Slashes"
  echo "###############################################"
  set -x

  if [[ -n "${DOCUMENT_ROOT}" ]]; then
    sed -i "s|DocumentRoot.*|DocumentRoot ${DOCUMENT_ROOT}|g" /etc/apache2/sites-available/vhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# Alias Config"
  echo "###############################################"
  set -x

  if [[ -n "${ALIASES}" ]]; then
    sed -i '/Alias/d' /etc/apache2/sites-available/vhost.conf

    SaveIFS=${IFS}
    IFS=';' read -ra aliases <<<"${ALIASES}"
    IFS=${SaveIFS}

    for alias in "${aliases[@]}"; do
      sed -i "/#ALIASES/a Alias $alias" /etc/apache2/sites-available/vhost.conf
    done
  fi
fi

set -x

exec "$@"
