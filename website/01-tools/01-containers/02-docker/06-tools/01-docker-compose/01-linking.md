---
layout: page
title: Линковка Docker контейнеров с помощью Docker Compose
description: Линковка Docker контейнеров с помощью Docker Compose
keywords: devops, containers, docker, tools, docker-compose, linking
permalink: /devops/containers/docker/tools/docker-compose/linking/
---

# Линковка Docker контейнеров с помощью Docker Compose

С помощью Docker Compose создаем файл YML с инструкциями о том, какие контейнеры запускать и как линковать их между собой.

<br/>

    # docker-compose -v
    docker-compose version: 1.5.1

<br/>

    $ docker pull tomcat

    $ docker history tomcat | grep -i expose

<br/>

    $ vi docker-compose.yml

<br/>

    tomcatapp:
      image: tomcat
      ports:
       - "8080"

<br/>

// -d - to start your application in the background

    $ docker-compose -f docker-compose.yml up -d

    $ docker-compose -f docker-compose.yml ps


        Name             Command       State            Ports
    -------------------------------------------------------------------
    tmp_tomcatapp_1   catalina.sh run   Up      0.0.0.0:32768->8080/tcp

<br/>

    $ docker-compose -f docker-compose.yml logs
    $ docker-compose -f docker-compose.yml stop
    $ docker-compose -f docker-compose.yml rm

<br/>

    $ curl localhost:32768

<br/>

http://localhost:32768/

<br/>

### Посложнее пример

    $ vi compose-ex2.yml

К сожалению у меня нет этого war

<br/>

    nginx:
      image: nginx
      links:
       - tomcatapp1:tomcatapp1
       - tomcatapp2:tomcatapp2
       - tomcatapp3:tomcatapp3
      ports:
       - "80:80"
      volumes:
       - nginx.conf:/etc/nginx/nginx.conf
    tomcatapp1:
      image: tomcat
      volumes:
       - sample.war:/usr/local/tomcat/webapps/sample.war
    tomcatapp2:
      image: tomcat
      volumes:
       - sample.war:/usr/local/tomcat/webapps/sample.war
    tomcatapp3:
      image: tomcat
      volumes:
       - sample.war:/usr/local/tomcat/webapps/sample.war

<br/>

    $ vi nginx.conf

<br/>

    worker_processes 1;

    events { worker_connections 1024; }

    http {

        sendfile on;

        gzip              on;
        gzip_http_version 1.0;
        gzip_proxied      any;
        gzip_min_length   500;
        gzip_disable      "MSIE [1-6]\.";
        gzip_types        text/plain text/xml text/css
                          text/comma-separated-values
                          text/javascript
                          application/x-javascript
                          application/atom+xml;

        # List of application servers
        upstream app_servers {

            server tomcatapp1:8080;
            server tomcatapp2:8080;
            server tomcatapp3:8080;

        }

        # Configuration for the server
        server {

            # Running port
            listen [::]:80;
            listen 80;

            # Proxying the connections connections
            location / {

                proxy_pass         http://app_servers;
                proxy_redirect     off;
                proxy_set_header   Host $host;
                proxy_set_header   X-Real-IP $remote_addr;
                proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header   X-Forwarded-Host $server_name;

            }
        }
    }

<br/>

    $ export COMPOSE_FILE=compose-ex2.yml

    $ docker-compose up -d

    $ docker-compose ps

    $ docker exec composetest_nginx_1 cat /etc/hosts

    $ docker exec composetest_tomcatapp1_1 ip a

    $ docker exec composetest_tomcatapp2_1 ip a

    $ docker exec composetest_tomcatapp3_1 ip a

    $ curl http://localhost/sample/

    $ docker-compose stop

<br/>

### Еще 1 пример конфига

    $ vi docker-compose.yml

<br/>

    django:
      image: username/image:latest
      command: python manage.py supervisor
      environment:
        RUN_ENV: "$RUN_ENV"
      ports:
       - "80:8001"
      volumes:
       - .:/project
      links:
       - redis
       - postgres

    celery_worker:
      image: username/image:latest
      command: python manage.py celery worker -l info
      links:
       - postgres
       - redis

    postgres:
      image: postgres:9.1
      volumes:
        - local_postgres:/var/lib/postgresql/data
      ports:
       - "5432:5432"
      environment:
        POSTGRES_PASSWORD: "$POSTGRES_PASSWORD"
        POSTGRES_USER: "$POSTGRES_USER"

    redis:
      image: redis:latest
      command: redis-server --appendonly yes

<br/>

    $ docker-compose up

или

    $ docker-compose up --no-deps -d postgres

http://dou.ua/lenta/articles/docker/
