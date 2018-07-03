FROM php:7.1-apache-stretch

ENV RELAYHOST=default

COPY ./install-global.sh /usr/local/bin/install-global.sh
COPY ./install-test.sh /usr/local/bin/install-test.sh

RUN chmod +x /usr/local/bin/install-global.sh \
	&& /usr/local/bin/install-global.sh

RUN chmod +x /usr/local/bin/install-test.sh 

#RUN chmod +x /usr/local/bin/install-test.sh \
#	&& /usr/local/bin/install-test.sh

RUN echo "##${RELAYHOST}" >> /etc/postfix/main.cf

ENTRYPOINT ["install-test.sh"]
CMD ["apache2-foreground"]
