#!/bin/bash

set -ex

echo "###############################################"
echo "ME: Install and Configure Packages"
echo "###############################################"

echo "# Update & Upgrade"
echo "-------------------------------"
apt-get update \
    && apt-get upgrade -y

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y locales apt-transport-https nano git net-tools iproute2 mailutils gnupg libxml2-dev \
	libbz2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libmcrypt-dev libmemcached-dev \
	libsqlite3-dev libssl-dev libz-dev libz-dev zlib1g-dev libsqlite3-dev zip libxml2-dev rsyslog cron libzip-dev \
	libcurl3-dev libedit-dev libpspell-dev libldap2-dev unixodbc-dev libpq-dev wget libc-client-dev libkrb5-dev libpcre3-dev \
	libsasl2-modules iputils-ping rsync sudo lftp acl ssh lsb-release gnupg2 ca-certificates software-properties-common curl

echo "# + Bugfix: libldap (https://bugs.php.net/bug.php?id=49876)"
echo "-------------------------------"
ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/

echo "# + sury apt-repo for php"
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
  && apt-get update

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

echo "# + install PHP-Extensions: GD, Mysql, Mysqli, Soap, Xdebug, ..."
echo "-------------------------------"
pear config-set php_ini /usr/local/etc/php/php.ini \
  && docker-php-ext-install pdo && docker-php-ext-enable pdo \
  && docker-php-ext-install pdo_mysql && docker-php-ext-enable pdo_mysql \
  && docker-php-ext-install pdo_sqlite && docker-php-ext-enable pdo_sqlite \
  && docker-php-ext-install mysqli && docker-php-ext-enable mysqli \
  && docker-php-ext-install soap && docker-php-ext-enable soap \
  && docker-php-ext-install pcntl && docker-php-ext-enable pcntl \
  && docker-php-ext-install zip && docker-php-ext-enable zip \
  && docker-php-ext-install curl && docker-php-ext-enable curl \
  && docker-php-ext-install bcmath && docker-php-ext-enable bcmath \
  && docker-php-ext-install opcache && docker-php-ext-enable opcache \
  && docker-php-ext-install simplexml && docker-php-ext-enable simplexml \
  && docker-php-ext-install xml && docker-php-ext-enable xml \
  && docker-php-ext-install session && docker-php-ext-enable session \
  && docker-php-ext-install pspell && docker-php-ext-enable pspell \
  && docker-php-ext-install ldap && docker-php-ext-enable ldap \
  && docker-php-ext-install exif && docker-php-ext-enable exif \
  && docker-php-ext-configure intl && docker-php-ext-install intl && docker-php-ext-enable intl \
  && pecl install oauth \
  && pear install DB \
  && pear install DB_Dataobject

echo "# + install Apache Modules: Rewrite, Remoteip, SSL, Headers, ... "
echo "-------------------------------"
a2enmod rewrite \
  && a2enmod ssl \
  && a2enmod remoteip \
  && a2enmod headers \
  && echo "RemoteIPHeader X-Forwarded-For" > /etc/apache2/conf-available/remoteip.conf \
  && echo "RemoteIPTrustedProxy 10.0.0.0/8" >> /etc/apache2/conf-available/remoteip.conf \
  && echo "RemoteIPTrustedProxy 172.16.0.0/12" >> /etc/apache2/conf-available/remoteip.conf \
  && echo "RemoteIPTrustedProxy 192.168.0.0/16" >> /etc/apache2/conf-available/remoteip.conf \
  && echo "RemoteIPTrustedProxy 81.201.32.0/20" >> /etc/apache2/conf-available/remoteip.conf \
  && echo "RemoteIPTrustedProxy 127.0.0.1" >> /etc/apache2/conf-available/remoteip.conf \
  && a2enconf remoteip

echo "# + install PHP Composer"
echo "-------------------------------"
wget -O /tmp/composer-setup.php --no-check-certificate 'https://getcomposer.org/installer' \
  && wget -O /tmp/composer-setup.sig --no-check-certificate 'https://composer.github.io/installer.sig' \
  && php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === trim(file_get_contents('/tmp/composer-setup.sig'))) { echo 'PHP-Composer-Installer verified'; } else { echo 'PHP-Composer-Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;" \
  && php /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer \
  && rm /tmp/composer-setup.php \
  && rm /tmp/composer-setup.sig

echo "# + install Symfony"
echo "-------------------------------"
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
apt install symfony-cli

echo "# + install imagemagick + PerlMagick"
echo "-------------------------------"
apt-get install -y imagemagick perlmagick

echo "# + install Apache Vhost"
echo "-------------------------------"
a2dissite 000-default \
  && a2ensite vhost.conf

echo "# + config Postfix"
echo "-------------------------------"

# nur IPv4
sed -i "s/inet_protocols.*=.*/inet_protocols = ipv4/g" /etc/postfix/main.cf

# SASL vorbereiten
if ! grep "^smtp_tls_security_level" /etc/postfix/main.cf -q; then
  echo "smtp_tls_security_level = may" >> /etc/postfix/main.cf
fi
echo "smtp_sasl_auth_enable = no" >> /etc/postfix/main.cf
echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_password" >> /etc/postfix/main.cf
echo "" > /etc/postfix/sasl_password
postmap /etc/postfix/sasl_password

# Sender
echo "#sender_canonical_maps = regexp:/etc/postfix/sender_canonical" >> /etc/postfix/main.cf
echo "" > /etc/postfix/sender_canonical

# Header
echo "#smtp_header_checks = regexp:/etc/postfix/header_check" >> /etc/postfix/main.cf
echo "" > /etc/postfix/header_check

# smtputf8_enable
echo "#smtputf8_enable = no" >> /etc/postfix/main.cf



