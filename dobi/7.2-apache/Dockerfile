FROM php:7.2-apache-stretch

# ENV
ENV APACHE_DOC_ROOT="/var/www/html"
ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"
ENV APACHE_RUN_DIR="/var/run/apache2"
ENV APACHE_LOG_DIR="/var/log/apache2"
ENV APACHE_LOCK_DIR="/var/lock/apache2"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV SERVER_NAME="me-base.garmisch.net"
ENV MYHOSTNAME="me-base.garmisch.net"
ENV DOCUMENT_ROOT="/var/www/html"
ENV DOCKER_HOST_IP="127.0.0.1"
ENV RELAYHOST="mx2.garmisch.net"
ENV REMOTE_IP_PROXY=""
ENV ALIASES=""

# Config-Files
COPY ./config/postfix.ini /usr/local/etc/php/conf.d/
COPY ./config/default-php.ini /usr/local/etc/php/conf.d/
COPY ./config/remoteip.conf /etc/apache2/conf-available/
COPY ./config/vhost.conf /etc/apache2/sites-available/
COPY ./start-container.sh /usr/local/bin/start-container.sh

# RUN IT
RUN apt-get update \
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
	&& docker-php-ext-install gd pdo pdo_mysql mysqli iconv mbstring \
	&& a2enmod rewrite \
	&& a2enmod remoteip \
	&& pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& pear install DB \
	&& pear install DB_Dataobject \
	&& a2enconf remoteip \
	&& a2dissite 000-default \
	&& a2ensite vhost.conf \
	&& chmod +x /usr/local/bin/start-container.sh

WORKDIR /var/www/html

EXPOSE 80

CMD ["/usr/local/bin/start-container.sh"]