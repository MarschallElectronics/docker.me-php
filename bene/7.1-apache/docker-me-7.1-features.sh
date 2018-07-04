#!/bin/bash

echo "###############################################"
echo "ME: install-7.1-features"
echo "###############################################"

pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring