#!/bin/bash

DOCKERFILE=$1
TAG=''

if [ -e ${DOCKERFILE} ]
then
	TAG=$(echo ${DOCKERFILE} | grep "^Dockerfile-" | cut -c 12-)
fi

if [ "X" != "X${TAG}" ]
then
	docker build --no-cache -t marschallelectronics/me-php:${TAG} -f ${DOCKERFILE} . \
	&& docker push marschallelectronics/me-php:${TAG}
else
	echo "No TAG available!"
fi
