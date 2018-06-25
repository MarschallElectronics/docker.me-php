#!/bin/bash

docker build -t marschallelectronics/me_base-php:7.1-apache .
#docker push marschallelectronics/me_base-php:7.1-apache

read -p "Press Enter to Exit" var