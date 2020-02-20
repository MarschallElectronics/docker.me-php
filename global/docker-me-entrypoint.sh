#!/bin/bash

#
# Vorsicht: Zeilenumbruch immer auf LF stellen!
#
# [ -n "${SERVER_NAME}" ] -> -n ZEICHENKETTE : Die Laenge von ZEICHENKETTE ist ungleich Null
# [ -f /etc/apache2/apache2.conf ] -> pruefen ob Datei vorhanden
# [ -z "$(mount | grep /etc/apache2/apache2.conf)" ] -> pruefen ob Datei reingemappt wurde (Sonst kommt Fehler "Device is busy")
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

export DOCKER_HOST_IP
export MYHOSTNAME
export SERVER_NAME
export POSTFIX_MYHOSTNAME
export POSTFIX_MYDESTINATION
export POSTFIX_SMTP_USERNAME
export POSTFIX_SMTP_PASSWORD
export POSTFIX_SMTP_AUTHTLS
export POSTFIX_SMTP_SENDER
export POSTFIX_SENDER_CANONICAL_MAPS
export POSTFIX_SENDER_HEADER_CHANGE
export RELAYHOST
export RELAYHOST_PORT
export DOCUMENT_ROOT
export ALIASES
export REMOTE_IP_PROXY
export START_RSYSLOGD
export START_CROND
export START_POSTFIX
export APACHE_TIMEOUT
export SSL_VHOST
export SSL_CERT
export SSL_CACERT
export SSL_PRIVATEKEY
export PHP_ENABLE_XDEBUG

# DOCKER_HOST_IP über Route setzen
# @todo funzt nicht weil netzwerk zum entrypoint-zeitpunkt noch nicht aktiv ist -> über command lösen
#if [[ "${DOCKER_HOST_IP}" == '127.0.0.1' ]]; then
#  DOCKER_HOST_IP="$(/sbin/ip route | awk '/default/ { print $3 }')"
#fi

# Fullqualified Hostname setzen
# @todo: funzt nicht, muss auch über command gemacht werden
#if [[ "${MYHOSTNAME}" == 'docker.garmisch.net' ]]; then
#  MYHOSTNAME=$(hostname --fqdn)
#fi

set +x
echo "###############################################"
echo "# Unable to get Full Qualified Servername Workaround"
echo "###############################################"
set -x

if [[ -n "${SERVER_NAME}" ]] && [[ -f /etc/apache2/apache2.conf ]] && [[ -z "$(mount | grep /etc/apache2/apache2.conf)" ]]; then
  echo "ServerName ${SERVER_NAME}" >>/etc/apache2/apache2.conf
fi

set +x
echo "###############################################"
echo "# PHP Extensions "
echo "###############################################"
set -x

if [[ ${PHP_ENABLE_XDEBUG} == 'yes' ]]; then
  sed -i "s/;zend_extension/zend_extension/g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
else
  sed -i "s/^zend_extension/;zend_extension/g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

set +x
echo "###############################################"
echo "# POSTFIX Config"
echo "###############################################"
set -x

if [[ -f /etc/postfix/main.cf ]] && [[ -z "$(mount | grep /etc/postfix/main.cf)" ]]; then

  # Mydestination nur auf localhost
  echo "mydestination anpassen..."
  sed -i "s/mydestination.*=.*/mydestination = ${POSTFIX_MYDESTINATION}/g" /etc/postfix/main.cf

  # Wenn Hostname vorhanden dann als Hostname fÃƒÂ¼r Postfix nehmen
  # Problem: manchmal wird nicht der komplette Hostname (FQDN) verwendet. Es werden dann keine Mails versendet :-(.
  if [[ -n "${MYHOSTNAME}" ]]; then
    echo "${MYHOSTNAME}" >/etc/mailname
    sed -i "s/myhostname.*=.*/myhostname = ${MYHOSTNAME}/g" /etc/postfix/main.cf
  fi

  # Wenn Postfix-Hostname gesetzt wurde, dann den verwenden
  if [[ -n "${POSTFIX_MYHOSTNAME}" ]]; then
    echo "${POSTFIX_MYHOSTNAME}" > /etc/mailname
    sed -i "s/myhostname.*=.*/myhostname = ${POSTFIX_MYHOSTNAME}/g" /etc/postfix/main.cf
  fi

  # Relayhost
  if [[ -n "${RELAYHOST}" ]]; then
    sed -i "s/relayhost.*=.*/relayhost = ${RELAYHOST}:${RELAYHOST_PORT}/g" /etc/postfix/main.cf
  fi

  # SASL
  if [[ -n "${POSTFIX_SMTP_USERNAME}" ]] && [[ -n "${POSTFIX_SMTP_PASSWORD}" ]]; then
    sed -i "s/smtp_sasl_auth_enable.*=.*/smtp_sasl_auth_enable = yes/g" /etc/postfix/main.cf

    if [[ ${POSTFIX_SMTP_AUTHTLS} == 'yes' ]]; then
      sed -i "s/smtp_tls_security_level.*=.*/smtp_tls_security_level = encrypt/g" /etc/postfix/main.cf
    fi

    if [[ -n "${POSTFIX_SMTP_USERNAME}" ]] && [[ -n "${RELAYHOST}" ]]; then
      echo "${RELAYHOST} ${POSTFIX_SMTP_USERNAME}:${POSTFIX_SMTP_PASSWORD}" > /etc/postfix/sasl_password
      postmap /etc/postfix/sasl_password
    fi
  fi

  # Header-Change aktivieren
  if [[ ${POSTFIX_SENDER_HEADER_CHANGE} == 'yes' ]] && [[ -n "${POSTFIX_SMTP_SENDER}" ]]; then
    # Header-Change
    sed -i "s/#smtp_header_checks/smtp_header_checks/g" /etc/postfix/main.cf

    # header_check
    echo "/From:.*/ REPLACE From: ${POSTFIX_SMTP_SENDER}" > /etc/postfix/header_check
  fi

  # sender_canonical_maps aktivieren
  if [[ ${POSTFIX_SENDER_CANONICAL_MAPS} == 'yes' ]] && [[ -n "${POSTFIX_SMTP_SENDER}" ]]; then
    # sender_canonical datei erstellen
    echo "/.+/ ${POSTFIX_SMTP_SENDER}" > /etc/postfix/sender_canonical

    # (wird z.B. für gmx benötigt --> Vorsicht: REPLY-TO kann dann aber nicht gesetzt werden)
    sed -i  "s/#sender_canonical_maps/sender_canonical_maps/g" /etc/postfix/main.cf
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
echo "# RemoteIp Config (wenn REMOTE_IP_PROXY nicht gesetzt, wird DOCKER_HOST_IP verwendet - DOCKER_HOST_IP wird über route ausgelesen.) "
echo "###############################################"
set -x

if [[ -f /etc/apache2/conf-available/remoteip.conf ]] && [[ -z "$(mount | grep /etc/apache2/conf-available/remoteip.conf)" ]]; then
  if [[ -z "${REMOTE_IP_PROXY}" ]]; then
    REMOTE_IP_PROXY=${DOCKER_HOST_IP}
  fi

  if [[ -n "${REMOTE_IP_PROXY}" ]]; then
    sed -i "s/RemoteIPTrustedProxy.*/RemoteIPTrustedProxy ${REMOTE_IP_PROXY}/g" /etc/apache2/conf-available/remoteip.conf
  fi
fi

set +x
echo "###############################################"
echo "# HTTP: Apache Conf"
echo "###############################################"
set -x

if [[ -f /etc/apache2/sites-available/vhost.conf ]] && [[ -z "$(mount | grep /etc/apache2/sites-available/vhost.conf)" ]]; then
  set +x
  echo "###############################################"
  echo "# HTTP: SERVER_NAME / Document Root"
  echo "###############################################"
  set -x

  if [[ -n "${SERVER_NAME}" ]]; then
    sed -i "s/ServerName.*/ServerName ${SERVER_NAME}/g" /etc/apache2/sites-available/vhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# HTTP: Document Root"
  echo "###############################################"
  set -x

  if [[ -n "${DOCUMENT_ROOT}" ]]; then
    sed -i "s|DocumentRoot.*|DocumentRoot ${DOCUMENT_ROOT}|g" /etc/apache2/sites-available/vhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# HTTP: Apache Timeout setzen"
  echo "###############################################"
  set -x

  if [[ -n "${APACHE_TIMEOUT}" ]] && [[ ${APACHE_TIMEOUT} != '300' ]]; then
    sed -i "s|Timeout.*|Timeout ${APACHE_TIMEOUT}|g" /etc/apache2/sites-available/vhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# HTTP: Alias Config"
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

# SSL_VHOST
if [[ ${SSL_VHOST} == 'yes' ]] && [[ -f /etc/apache2/sites-available/sslvhost.conf ]] && [[ -z "$(mount | grep /etc/apache2/sites-available/sslvhost.conf)" ]]; then
  set +x
  echo "###############################################"
  echo "# HTTPS: SERVER_NAME "
  echo "###############################################"
  set -x

  if [[ -n "${SERVER_NAME}" ]]; then
    sed -i "s/ServerName.*/ServerName ${SERVER_NAME}/g" /etc/apache2/sites-available/sslvhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# HTTPS: Document Root"
  echo "###############################################"
  set -x

  if [[ -n "${DOCUMENT_ROOT}" ]]; then
    sed -i "s|DocumentRoot.*|DocumentRoot ${DOCUMENT_ROOT}|g" /etc/apache2/sites-available/sslvhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# HTTPS: Apache Timeout setzen"
  echo "###############################################"
  set -x

  if [[ -n "${APACHE_TIMEOUT}" ]]; then
    sed -i "s|Timeout.*|Timeout ${APACHE_TIMEOUT}|g" /etc/apache2/sites-available/sslvhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# HTTPS: SSL-Zertifikate"
  echo "###############################################"
  set -x

  if [[ -n "${SSL_CERT}" ]]; then
    sed -i "s|SSLCertificateFile\s*/etc/ssl/certs/ssl-cert-snakeoil.pem|SSLCertificateFile ${SSL_CERT}|g" /etc/apache2/sites-available/sslvhost.conf
  fi

  if [[ -n "${SSL_PRIVATEKEY}" ]]; then
    sed -i "s|SSLCertificateKeyFile\s*/etc/ssl/private/ssl-cert-snakeoil.key|SSLCertificateKeyFile ${SSL_PRIVATEKEY}|g" /etc/apache2/sites-available/sslvhost.conf
  fi

  if [[ -n "${SSL_CACERT}" ]]; then
    sed -i "s|\#SSLCertificateChainFile\s*/etc/apache2/ssl.crt/server-ca.crt|SSLCertificateChainFile ${SSL_CACERT}|g" /etc/apache2/sites-available/sslvhost.conf
  fi

  set +x
  echo "###############################################"
  echo "# HTTPS: Alias Config"
  echo "###############################################"
  set -x

  if [[ -n "${ALIASES}" ]]; then
    sed -i '/Alias/d' /etc/apache2/sites-available/sslvhost.conf

    SaveIFS=${IFS}
    IFS=';' read -ra aliases <<<"${ALIASES}"
    IFS=${SaveIFS}

    for alias in "${aliases[@]}"; do
      sed -i "/#ALIASES/a Alias $alias" /etc/apache2/sites-available/sslvhost.conf
    done
  fi

  set +x
  echo "###############################################"
  echo "# HTTPS: activate Apache SSL-Vhost"
  echo "###############################################"
  set -x
  a2ensite sslvhost.conf

fi

set -x

exec "$@"
