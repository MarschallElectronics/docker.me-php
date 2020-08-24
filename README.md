# me-php Images

Die me-php Images geben eine schnelle und einfache Möglichkeit einen Webserver auf Docker-Basis aufzusetzen. <br>
**Nachfolgend wird als _hosting name_ `me-team.net` genutzt!**

## Getting Started

Man erstellt eine docker-compose.yml unter /srv/www/vhosts/`me-team.net`/docker/docker-compose.yml <br>
Diese wird wie im nächsten punkt erläutert.

### Versionen:
Versionen des me-php Images werden mit dem Tag unterschieden, welches nach dem ":" steht.<br> 
Bis auf die PHP Version und davon abhängige Versionen unterscheiden sich die Images nicht.

### Apache-Module:
core_module, so_module, watchdog_module, http_module, log_config_module, logio_module, version_module, unixd_module, 
access_compat_module, alias_module, auth_basic_module, authn_core_module, authn_file_module, authz_core_module, 
authz_host_module, authz_user_module, autoindex_module, deflate_module, dir_module, env_module, filter_module, 
headers_module, mime_module, mpm_prefork_module, negotiation_module, php7_module, remoteip_module, reqtimeout_module, 
rewrite_module, setenvif_module, socache_shmcb_module, ssl_module, status_module

### PHP-Extensions:
[PHP Modules] : apcu bcmath Core ctype curl date dom exif fileinfo filter ftp gd hash iconv json ldap libxml mbstring mcrypt mysqli mysqlnd OAuth openssl pcntl pcre PDO pdo_mysql pdo_sqlite pdo_sqlsrv Phar posix pspell readline Reflection session SimpleXML soap SPL sqlite3 sqlsrv standard tokenizer xdebug xml xmlreader xmlrpc xmlwriter Zend OPcache zip zlib<br/>
[Zend Modules] : Xdebug Zend OPcache

# Apps
nano, git, composer, yarn, nodejs, npm 

### Envorinment Variablen

Envorinment Variablen werden dazu genutzt um das Image für das jeweilige hosting anzupassen.<br>

Für diese Images gibt es folgende Envorinment-Variablen: <br>

* `DOCKER_HOST_IP` - _IP-Adresse des Docker-Host-Containers_
* `SERVER_NAME` - Fully qualified domain name  (Default: me-php.garmisch.net)
* `MYHOSTNAME` - Alias für SERVER_NAME für Postfix
* `REMOTE_IP_PROXY` - IP Adresse des ReverseProxy (Default: Host_IP)
* `RELAYHOST` - Adresse des Relay-Servers
* `RELAYHOST_PORT` - Port des Relay-Servers
* `POSTFIX_MYHOSTNAME` - Myhostname für Postfix
* `POSTFIX_MYDESTINATION` - MYDESTINATION für Postfix (Default: localhost.localdomain, localhost)
* `POSTFIX_SMTP_USERNAME` - USERNAME für SMTP-Versand (SASL-Auth)
* `POSTFIX_SMTP_PASSWORD` - PASSWORD für SMTP-Versand (SASL-Auth)
* `POSTFIX_SMTP_AUTHTLS` - SASL-Auth mit TLS [yes|no] (Default: no)
* `POSTFIX_SMTP_SENDER` - Absender auf diese Mailadresse ändern
* `POSTFIX_SENDER_CANONICAL_MAPS` - sender_canonical_maps aktivieren. Absender-Adresse wird auf POSTFIX_SMTP_SENDER gesetzt. Vorsicht: REPLY-TO funktioniert damit nicht!
* `POSTFIX_SENDER_HEADER_CHANGE` - smtp_header_checks aktivieren. Absender-Adresse wird auf POSTFIX_SMTP_SENDER gesetzt. Vorsicht: Hostname muss valid und auflösbar sein!
* `DOCUMENT_ROOT` - Document Root für apache (Ordner der index.html/php)
* `ALIASES` - Eine Liste von Aliasen für den Apache mit ";" getrennt.
* `START_RSYSLOGD` - _Soll der Syslog-Daemon gestartet werden (Default: no)_
* `START_CROND` - _Soll der Cron-Daemon gestartet werden (Default: no)_
* `START_POSTFIX` - _Soll Postfix gestartet werden (Default: yes)_
* `APACHE_TIMEOUT` - _Timeout für Apache2 in Sekunden (default:300)_
* `SSL_VHOST` - _SSL-Vhost aktivieren? Zertifikats-Dateien müssen über volume reingemappt werden. [yes|no] (default: no)_
* `SSL_CERT` - _Pfad zum SSL-Zertifikat (bsp: /etc/ssl/sslvw/mycandy.de/certificate.crt)_
* `SSL_CACERT` - _Pfad zum SSL-CA-Zertifikat (bsp: /etc/ssl/sslvw/mycandy.de/cert.bundle)_
* `SSL_PRIVATEKEY` - _Pfad zum SSL-Private-Key (bsp: /etc/ssl/sslvw/mycandy.de/private.key)_
* `PHP_ENABLE_XDEBUG` - _XDEBUG PHP-Extension aktivieren / mit Option um Modul-Datei zu aktivieren [yes|no] (Default: no)_
* `PHP_ENABLE_SQLSRV` - _SQLSRV PHP-Extension aktivieren / mit Option um Modul-Datei zu aktivieren [yes|no] (Default: no)_

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
