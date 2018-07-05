# ME_Base-php Images

Die ME_Base-php Images geben eine schnelle und einfache Möglichkeit einen Webserver auf Docker-Basis aufzusetzen. <br>
**Nachfolgend wird als _hosting name_ `me-team.net` genutzt!**

## Getting Started

Man erstellt eine docker-compose-www.yml unter /srv/www/vhosts/`me-team.net`/docker/docker-compose-www.yml <br>
Diese wird wie im nächsten punkt erläutert.

### Versionen:
Derzeit gibt es 2 Versionen des ME_Base-php Images diese werden mit dem Tag unterschieden, welches nach dem ":" steht. Bis auf die PHP Version und davon abhängige Versionen unterscheiden sich die Images nicht.
* `marschallelectronics/me_base-php:5.6-apache` - PHP Version 5.6
* `marschallelectronics/me_base-php:7.1-apache` - PHP Version 7.1

### docker-compose-www.yml

```
version: '3'

services:
    webserver_me_team:
        container_name: webserver_me_team
        image: marschallelectronics/me_base-php:7.1-apache
        volumes:
            - ../public/www/:/var/www/html/
        ports:
            - '8020:80'
        environment:
            SERVER_NAME: me-team.net
            REMOTE_IP_PROXY: 172.18.0.1
            RELAYHOST: mx2.garmisch.net:25
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

### Envorinment Variablen

Envorinment Variablen werden dazu genutzt um das Image für das jeweilige hosting anzupassen.<br>
_Beispiele unter docker-compose-www.yml_

Für diese Images werden folgende Envorinment variablen benötigt. <br>

* `SERVER_NAME` - Fully qualified domain name
* `REMOTE_IP_PROXY` - IP Adresse des ReverseProxy _(Default: Host_IP)_
* `RELAYHOST` - Domain des Relay Server
* `DOCUMENT_ROOT` - Document Root für apache (Ordner der index.html/php)
* `ALIASES` - _(Optional) Eine liste von Aliasen für den Apache mit ";" getrennt._

## Startscript für SystemD

Um die Docker-Container dauerhaft laufen zu lassen und das sie sich nach Fehlern neu starten erstellen wir einen SystemD Dienst.
Hierzu legen wir eine `docker-me-team.service` unter _/etc/systemd/system/multi-user.target.wants/_ an, und passen folgenden text für das Hosting an.

```
[Unit]
Description=Webserver fuer me-team.net
After=network.target docker.service

[Service]
Type=simple
WorkingDirectory=/srv/www/vhosts/me-team.net/docker
ExecStart=/usr/local/bin/docker-compose -f /srv/www/vhosts/me-team.net/docker/docker-compose-www.yml up
ExecStop=/usr/local/bin/docker-compose -f /srv/www/vhosts/me-team.net/docker/docker-compose-www.yml down
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

```

Hat man eine das Startscript angelegt, muss man dieses noch aktivieren. Dies geschieht über den Befehl systemctl mit Root-Rechten.
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
`RequestHeader set X-Forwarded-Proto "https"` muss in den SSL Teil der config eingetragen werden.

IMPORTANT: Dieser Header muss für JOOMLA Seiten gesetzt werden damit "HTTPS=on" gesetzt wird, da Joomla sonst keine Inhalte via. HTTPS:// bereitstellt!

## Authoren

* **Tobias Bergkofer** - [Nightscore](https://github.com/Nightscore)
* **Benedict Reuthlinger** - [BeneReuthlinger](https://github.com/BeneReuthlinger)


TEST