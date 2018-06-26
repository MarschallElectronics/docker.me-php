FROM php:5.6-apache

# Default Server ENV
ENV SERVER_NAME me-base.garmisch.net

# SSMTP ENV
ENV RELAYHOST mx2.garmisch.net

# Apache ENV
ENV APACHE_DOC_ROOT /var/www/html
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

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
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ --with-vpx-dir=/usr/lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install mysql gd pdo pdo_mysql mysqli iconv mbstring \
	&& a2enmod rewrite \
	&& a2enmod remoteip

RUN pecl install apcu-4.0.11 \
	&& docker-php-ext-enable apcu

RUN pear install DB \
	&& pear install DB_Dataobject

ADD ./config/postfix.ini /usr/local/etc/php/conf.d/
ADD ./config/default-php.ini /usr/local/etc/php/conf.d/
ADD ./config/remoteip.conf /etc/apache2/conf-available/
ADD ./config/vhost.conf /etc/apache2/sites-available/

RUN a2enconf remoteip \
	&& a2dissite 000-default \
	&& a2ensite vhost.conf

COPY start-container.sh /usr/local/bin/start-container.sh
RUN chmod +x /usr/local/bin/start-container.sh

WORKDIR /var/www/html

EXPOSE 80

CMD ["/usr/local/bin/start-container.sh"]