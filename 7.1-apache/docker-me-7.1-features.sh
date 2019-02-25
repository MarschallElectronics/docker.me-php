#!/bin/bash

set -e

echo "###############################################"
echo "ME: install-7.1-features"
echo "###############################################"

# PHP-Ext: APCU, iconv, mbstring, Mcrypt (Deprecated in 7.2)
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring mcrypt