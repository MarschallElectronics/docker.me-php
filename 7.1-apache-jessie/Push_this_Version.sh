#!/bin/bash

docker build -t marschallelectronics/me_base-php:7.1-apache-jessie .
docker push marschallelectronics/me_base-php:7.1-apache-jessie

read -p "Press Enter to Exit" var