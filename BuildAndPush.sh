#!/bin/bash

DOCKERFILE=$1
TAG=''

if [ -e "${DOCKERFILE}" ]
then
	TAG=$(echo "${DOCKERFILE}" | grep "^Dockerfile-" | cut -c 12-)
fi

if [ "X" != "X${TAG}" ]
then
	docker build --no-cache -t "marschallelectronics/me-php:${TAG}" -f "${DOCKERFILE}" . || exit 1
	docker push "marschallelectronics/me-php:${TAG}" || exit 1
else
	echo "No TAG available!"
fi

# latest
if [ "${TAG}" == "7.4-apache" ]
then
	docker build --no-cache -t marschallelectronics/me-php:latest -f "${DOCKERFILE}" . || exit 1
	docker push marschallelectronics/me-php:latest || exit 1
else
	echo "No TAG available!"
fi

exit 0