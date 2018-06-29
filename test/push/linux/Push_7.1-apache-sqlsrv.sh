#!/bin/bash

docker build -t marschallelectronics/me_base-php:7.1-apache-sqlsrv -f ../../Dockerfile-7.1-apache-sqlsrv ../..
docker push marschallelectronics/me_base-php:7.1-apache-sqlsrv

read -p "Press Enter to Exit" var