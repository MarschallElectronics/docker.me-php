#!/bin/bash

docker build -t marschallelectronics/me_base-php:5.6-apache -f ../../Dockerfile-5.6-apache ../..
docker push marschallelectronics/me_base-php:5.6-apache

read -p "Press Enter to Exit" var