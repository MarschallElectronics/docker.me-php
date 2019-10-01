# me-php Images

Die me-php Images geben eine schnelle und einfache Möglichkeit einen Webserver auf Docker-Basis aufzusetzen. <br>
**Nachfolgend wird als _hosting name_ `me-team.net` genutzt!**

## Getting Started

Man erstellt eine docker-compose.yml unter /srv/www/vhosts/`me-team.net`/docker/docker-compose.yml <br>
Diese wird wie im nächsten punkt erläutert.

### Versionen:
Versionen des me-php Images werden mit dem Tag unterschieden, welches nach dem ":" steht.<br> 
Bis auf die PHP Version und davon abhängige Versionen unterscheiden sich die Images nicht.

### Envorinment Variablen

Envorinment Variablen werden dazu genutzt um das Image für das jeweilige hosting anzupassen.<br>
_Beispiele unter docker-compose-www.yml_

Für diese Images werden folgende Envorinment variablen benötigt. <br>

* `DOCKER_HOST_IP` - _IP-Adresse des Docker-Containers (Default: 127.0.0.1)_
* `SERVER_NAME` - Fully qualified domain name  (Default: me-php.garmisch.net)
* `MYHOSTNAME` - Alias für SERVER_NAME für Postfix
* `REMOTE_IP_PROXY` - IP Adresse des ReverseProxy (Default: Host_IP)
* `RELAYHOST` - Domain des Relay Server
* `POSTFIX_MYHOSTNAME` - Myhostname für Postfix
* `DOCUMENT_ROOT` - Document Root für apache (Ordner der index.html/php)
* `ALIASES` - Eine Liste von Aliasen für den Apache mit ";" getrennt.
* `START_RSYSLOGD` - _Soll der Syslog-Daemon gestartet werden (Default: no)_
* `START_CROND` - _Soll der Cron-Daemon gestartet werden (Default: no)_
* `START_POSTFIX` - _Soll Postfix gestartet werden (Default: yes)_

### docker-compose.yml

```
version: '3'

services:
    webserver_me_team:
        container_name: webserver_me_team
        image: marschallelectronics/me-php:7.1-apache
        volumes:
            - ../public/www/:/var/www/html/
        ports:
            - '8020:80'
        environment:
            SERVER_NAME: me-team.net
            REMOTE_IP_PROXY: 172.18.0.1
            RELAYHOST: mx2.garmisch.net
            DOCUMENT_ROOT: /var/www/html
            ALIASES:
                /foo "/var/www/html/foo/";
                /bar "/var/www/html/bar/";
                /bsp "/var/www/html/bsp/";
```
* `container_name` - Eindeutiger Name des Containers **(Einzigartiger Name)**
* `image` - Name des Image das genutzt werden soll
* `volumes` - Eine Liste von "Volumes" die genutzt werden
* `ports` - Externer Port / Container Port
* `environment` - Variablen die an den Container gebeben werden **(Mehr im Nächstem Punkt)**

## Startscript für SystemD

Um die Docker-Container dauerhaft laufen zu lassen und das sie sich nach Fehlern neu starten erstellen wir einen SystemD Dienst.
Hierzu legen wir eine `docker-me-team.service` unter _/lib/systemd/system/_ an, und passen folgenden text für das Hosting an.

```
[Unit]
Description=Webserver fuer me-team.net
After=network.target docker.service

[Service]
Type=simple
WorkingDirectory=/srv/www/vhosts/me-team.net/docker
ExecStart=/usr/local/bin/docker-compose -f /srv/www/vhosts/me-team.net/docker/docker-compose.yml up
ExecStop=/usr/local/bin/docker-compose -f /srv/www/vhosts/me-team.net/docker/docker-compose.yml down
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

```

Hat man eine das Startscript angelegt, muss man dieses noch aktivieren, damit das OS den Docker-Container automatisch beim Systemstart startet. Dies geschieht über den Befehl systemctl mit Root-Rechten.
```
systemctl enable docker-me-team.service
```
Zum Deaktivieren dient der Befehl: 
```
systemctl disable docker-me-team.service
```

Das Starten des Containers geschieht über systemctl mit dem Befehl:
```
systemctl start docker-me-team.service
```
Zum Beenden dient der Befehl: 
```
systemctl stop docker-me-team.service
```
## SSL auf Container durchschleifen

In der default vhost.conf wird automatisch "HTTPS=on" gesetzt wenn der RequestHeader "X-Forwarded-Proto" auf "https" gesetzt ist.<br>
Um diesen Header übergeben zu können muss im Hostsystem die vhost.conf für das jeweilige hosting angepasst werden.<br> 
`RequestHeader set X-Forwarded-Proto "https"` muss in den SSL Teil der config eingetragen werden.<br>
Im Docker-Container wird in Apache-Config mittels `SetEnvIf X-Forwarded-Proto https HTTPS=on` der Header HTTPS auf on gesetzt.<br /> 
IMPORTANT: HTTPS=on wirkt nicht auf die .htaccess! D.h. eine Weiterleitung auf https muss über X-Forwarded-Proto gemacht werden: RewriteCond %{HTTP:X-Forwarded-Proto} !=https [NC]

## Repositories

* Github-Repository: https://github.com/MarschallElectronics/docker.me-php
* Lokal-Repository: https://git.garmisch.net/docker.me-php.git 

## Autoren

* **Tobias Bergkofer** - [Nightscore](https://github.com/Nightscore)
* **Benedict Reuthlinger** - [BeneReuthlinger](https://github.com/BeneReuthlinger)
