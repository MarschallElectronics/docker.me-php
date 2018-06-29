#!/bin/bash

echo "###############################################"
echo "ME: install-5.6-features"
echo "###############################################"

pecl install apcu-4.0.11 \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install mysql