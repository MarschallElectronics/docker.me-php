#!/bin/bash

docker build -t marschallelectronics/me_base-php:7.1-apache-test .
docker push marschallelectronics/me_base-php:7.1-apache-test

read -p "Press Enter to Exit" var