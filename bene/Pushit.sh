#!/bin/bash

DOCKERFILE=$1
TAG=''

if [ -e ${DOCKERFILE} ]
then
	TAG=$(echo ${DOCKERFILE} | grep "^Dockerfile-" | cut -c 12-)
fi

if [ -n ${TAG} ]
then
	echo "docker build -t marschallelectronics/me_base-php:${TAG} -f ${DOCKERFILE} ."
	echo "docker push marschallelectronics/me_base-php:${TAG}"
fi

read -p "Press Enter to Exit" var