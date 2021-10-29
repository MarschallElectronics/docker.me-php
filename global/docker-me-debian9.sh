#!/bin/bash

set -ex

echo "###############################################"
echo "ME: Install for Debian 9"
echo "###############################################"

echo "# + install diverse Apps"
echo "-------------------------------"
apt-get install -y mysql-client

echo "# + nodejs + npm"
echo "-------------------------------"
apt-get install -y nodejs \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
  && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install yarn

echo "# install: php gdlib"
echo "-------------------------------"
docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
  && docker-php-ext-install gd && docker-php-ext-enable gd