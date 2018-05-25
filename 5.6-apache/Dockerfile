FROM php:5.6-apache

# Default Server ENV
ENV SERVER_NAME me-base.garmisch.net

# SSMTP ENV
ENV SSMTP_MAILHUB mx2.garmisch.net:25

# Apache ENV
ENV APACHE_DOC_ROOT /var/www/html
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN apt-get update \
        && apt-get install -y --no-install-recommends locales apt-transport-https nano git ssmtp \
        && apt-get install -y libbz2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libmcrypt-dev libmemcached-dev \
        && apt-get upgrade -y \
        && echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen \
        && locale-gen \
        && apt-get update \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ --with-vpx-dir=/usr/lib/x86_64-linux-gnu/ \
        && docker-php-ext-install gd pdo pdo_mysql mysqli iconv mbstring \
        && a2enmod rewrite

ADD ./config/ssmtp.conf /etc/ssmtp/ssmtp.conf