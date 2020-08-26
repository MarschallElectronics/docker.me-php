#
# Für tischler-reisen.de erstellt, wurde nur teilweise getestet!
# IMAGE: mvstudio/php53-apache-legacy --> COMMAND: /usr/local/bin/apache_run.sh
# todo: eigenes Docker-Image auf Basis von debian:wheezy
#

FROM mvstudio/php53-apache-legacy
MAINTAINER Bene Reuthlinger <br@garmisch.net>

ENV TZ="Europe/Berlin"

# Config- und Script-Files
COPY ../5.3-apache/docker-me-5.3-features.sh /usr/local/bin/docker-me-5.3-features.sh
COPY ../global/docker-me-cleanup.sh /usr/local/bin/docker-me-cleanup.sh

# ausführbar machen
RUN chmod +x /usr/local/bin/docker-me-5.3-features.sh
RUN	chmod +x /usr/local/bin/docker-me-cleanup.sh

# ausführen
RUN /usr/local/bin/docker-me-5.3-features.sh
RUN /usr/local/bin/docker-me-cleanup.sh



