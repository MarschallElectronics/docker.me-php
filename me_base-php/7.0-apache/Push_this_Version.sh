#!/bin/bash

docker build -t marschallelectronics/me_base-php:7.0-apache .
docker push marschallelectronics/me_base-php:7.0-apache

read -p "Press Enter to Exit" var
