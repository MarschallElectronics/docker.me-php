#!/bin/bash

docker build -t marschallelectronics/me_base-php:7.2-apache -f ../Dockerfile-7.2-apache ..
docker push marschallelectronics/me_base-php:7.2-apache

read -p "Press Enter to Exit" var