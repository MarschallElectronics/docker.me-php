#!/bin/bash

set -ex

echo "###############################################"
echo "ME: Install and Configure Packages"
echo "###############################################"

echo "# Update & Upgrade"
echo "-------------------------------"
apt-get update

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y locales apt-transport-https nano git net-tools mailutils gnupg wget gcc make

echo "# + install postfix"
echo "-------------------------------"
echo "postfix postfix/main_mailer_type string Internet site" > /tmp/preseed.txt \
  && echo "postfix postfix/mailname string docker_web1.garmisch.net" >> /tmp/preseed.txt \
  && debconf-set-selections /tmp/preseed.txt \
  && DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y postfix \
  && rm /tmp/preseed.txt

echo "# + install Language DE"
echo "-------------------------------"
echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen

echo "# + install Apache Modules: Rewrite, Remoteip, SSL, Headers, ... "
echo "-------------------------------"
a2enmod rewrite \
  && a2enmod filter \
  && a2enmod expires \
  && a2enmod headers

echo "# + config Postfix"
echo "-------------------------------"

# nur IPv4
sed -i "s/inet_protocols.*=.*/inet_protocols = ipv4/g" /etc/postfix/main.cf

# SASL vorbereiten
echo "smtp_sasl_auth_enable = no" >> /etc/postfix/main.cf
echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
echo "smtp_tls_security_level = none" >> /etc/postfix/main.cf
echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_password" >> /etc/postfix/main.cf
echo "" > /etc/postfix/sasl_password
postmap /etc/postfix/sasl_password

# Sender
echo "#sender_canonical_maps = regexp:/etc/postfix/sender_canonical" >> /etc/postfix/main.cf
echo "" > /etc/postfix/sender_canonical

# Header
echo "#smtp_header_checks = regexp:/etc/postfix/header_check" >> /etc/postfix/main.cf
echo "" > /etc/postfix/header_check
