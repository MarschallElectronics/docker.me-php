#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.4-features"
echo "###############################################"

echo "# install: imagick" #
echo "-------------------------------"
apt-get -y install libmagickwand-dev --no-install-recommends \
  && printf "\n" | pecl install imagick \
  && docker-php-ext-enable imagick \
  && rm -r /var/lib/apt/lists/*


