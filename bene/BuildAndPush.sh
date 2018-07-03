#!/bin/bash

DOCKERFILE=$1
TAG=''

if [ -e ${DOCKERFILE} ]
then
	TAG=$(echo ${DOCKERFILE} | grep "^Dockerfile-" | cut -c 12-)
fi

if [ "X" != "X${TAG}" ]
then
	docker build -t marschallelectronics/me_base-php:${TAG} -f ${DOCKERFILE} .
	docker push marschallelectronics/me_base-php:${TAG}
else
	echo "No TAG available!"
fi
