#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.0-features"
echo "###############################################"

echo "# PHP-Ext: APCU, iconv, mbstring, Mcrypt (Deprecated in 7.2)"
echo "-------------------------------"
pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& docker-php-ext-install iconv mbstring mcrypt
