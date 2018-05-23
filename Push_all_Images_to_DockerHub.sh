#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for dir in $DIR/*/
do
    dir=${dir%*/}
    dir=${dir##*/}

    cd $DIR/${dir}
    docker build -t marschallelectronics/me_base-php:${dir} .
    docker push marschallelectronics/me_base-php:${dir}

done

docker build -t marschallelectronics/me_base-php:latest .
docker push marschallelectronics/me_base-php:latest

read -p "Press Enter to Exit" var