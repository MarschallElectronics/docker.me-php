#!/bin/bash

#########################################################################
# Usage
#
# Für neue Versionen Ordner und Tag anpassen
#
# Beispiel für 7.1-apache Image
# ------------------------------
# cd $DIR/7.1-apache
# docker build -t marschallelectronics/me_base-php:7.1-apache .
# docker push marschallelectronics/me_base-php:7.1-apache
#########################################################################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# PHP 7.1-Apache Image
cd $DIR/7.1-apache
docker build -t marschallelectronics/me_base-php:7.1-apache .
docker push marschallelectronics/me_base-php:7.1-apache



# Immer am Ende lassen damit "latest" immer die neuste version ist
docker build -t marschallelectronics/me_base-php:latest .
docker push marschallelectronics/me_base-php:latest

read -p "Press Enter to Exit" var