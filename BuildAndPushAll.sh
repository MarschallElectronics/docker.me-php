#!/bin/bash

echo -e "---------------------\n7.4-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-7.4-apache \
&& echo -e "---------------------\n8.0-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-8.0-apache \
&& echo -e "---------------------\n8.1-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-8.1-apache \
&& echo -e "---------------------\n8.1-apache-bullseye:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-8.1-apache-bullseye \
&& echo -e "---------------------\n8.2-apache:\n---------------------\n\n" \
&& bash BuildAndPush.sh Dockerfile-8.2-apache