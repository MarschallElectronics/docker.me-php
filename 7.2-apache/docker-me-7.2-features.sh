#!/bin/bash

set -e

echo "###############################################"
echo "ME: install-7.2-features"
echo "###############################################"

# PHP-Ext: APCU, iconv, mbstring
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring