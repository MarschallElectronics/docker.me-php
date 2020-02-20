#!/bin/bash

set -ex

echo "# Cleanup"
echo "-------------------------------"
apt-get autoremove -y \
  && apt-get clean all \
  && rm -rvf /var/lib/apt/lists/* \
  && rm -rvf /usr/share/doc /usr/share/man \
  && rm -rvf /usr/src/php \
  && rm -rvf /tmp/*
