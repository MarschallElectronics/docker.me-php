#!/bin/bash

set -ex

echo "###############################################"
echo "ME: install-7.4-features"
echo "###############################################"

# @todo
echo "# install: imagick" #
echo "-------------------------------"
#apt-get -y install libmagickwand-dev --no-install-recommends \
#  && printf "\n" | pecl install imagick \
#  && docker-php-ext-enable imagick \
#  && rm -r /var/lib/apt/lists/*

# workaround mit warnings
apt-get -y install libmagickwand-dev --no-install-recommends \
  && mkdir -p /usr/src/php/ext/imagick \
  && curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1 \
  && docker-php-ext-install imagick

