#!/bin/bash

DOCKERFILE=$1
TAG=''

if [ -e ${DOCKERFILE} ]
then
  POS=$(echo ${DOCKERFILE} | grep -b -o '/Dockerfile' | awk 'BEGIN {FS=":"}{print $1}')
  TAG=${DOCKERFILE:0:$POS}
fi

echo $TAG

if [ "X" != "X${TAG}" ]
then
  cd $TAG
  docker build --no-cache -t marschallelectronics/me-php:${TAG} -f Dockerfile . \
  && docker push marschallelectronics/me-php:${TAG} \
  || exit 1
else
	echo "No TAG available!"
	exit 1
fi

exit 0
