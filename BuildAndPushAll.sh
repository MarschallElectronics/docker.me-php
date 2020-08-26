#!/bin/bash

bash BuildAndPush.sh 5.6-apache/Dockerfile \
  && bash BuildAndPush.sh 7.0-apache/Dockerfile \
  && bash BuildAndPush.sh 7.1-apache/Dockerfile \
  && bash BuildAndPush.sh 7.1-apache-jessie/Dockerfile \
  && bash BuildAndPush.sh 7.1-apache-sqlsrv/Dockerfile \
  && bash BuildAndPush.sh 7.2-apache/Dockerfile \
  && bash BuildAndPush.sh 7.3-apache/Dockerfile \
  && bash BuildAndPush.sh 7.4-apache/Dockerfile \
  || exit 1

exit 0