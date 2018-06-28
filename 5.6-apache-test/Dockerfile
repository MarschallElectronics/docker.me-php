FROM php:5.6-apache-stretch

# Config-Files
COPY ./global/config/postfix-php.ini /usr/local/etc/php/conf.d/
COPY ./global/config/default-php.ini /usr/local/etc/php/conf.d/
COPY ./global/config/remoteip.conf /etc/apache2/conf-available/
COPY ./global/config/vhost.conf /etc/apache2/sites-available/
COPY ./global/envvars.sh /usr/local/bin/envvars.sh
COPY ./global/install-all.sh /usr/local/bin/install-all.sh
COPY ./global/configure-all.sh /usr/local/bin/configure-all.sh
COPY ./global/start.sh /usr/local/bin/start.sh

# RUN IT
RUN  chmod +x /usr/local/bin/envvars.sh \
	&& chmod +x /usr/local/bin/install-all.sh \
	&& chmod +x /usr/local/bin/configure-all.sh \
	&& /usr/local/bin/envvars.sh \
	&& /usr/local/bin/install-all.sh \
	&& /usr/local/bin/configure-all.sh

CMD ["/usr/local/bin/start.sh"]

WORKDIR /var/www/html
EXPOSE 80