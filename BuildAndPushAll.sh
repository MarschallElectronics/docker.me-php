#!/bin/bash

echo -e "---------------------\n5.6-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-5.6-apache \
&& echo -e "---------------------\n7.0-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.0-apache \
&& echo -e "---------------------\n7.1-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.1-apache \
&& echo -e "---------------------\n7.1-apache-jessie:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.1-apache-jessie \
&& echo -e "---------------------\n7.1-apache-sqlsrv:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.1-apache-sqlsrv \
&& echo -e "---------------------\n7.2-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.2-apache \
&& echo -e "---------------------\n7.3-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.3-apache \
&& echo -e "---------------------\n7.4-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.4-apache \
&& echo -e "---------------------\n8.0-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-8.0-apache \
&& echo -e "---------------------\n8.1-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-8.1-apache