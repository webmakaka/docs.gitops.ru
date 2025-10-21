---
layout: page
title: Работа с официальным mysql Docker контейнером
description: Работа с официальным mysql Docker контейнером
keywords: devops, docker, Работа с официальным mysql Docker контейнером
permalink: /devops/containers/docker/official/containers/mysql/
---

# Работа с официальным mysql Docker контейнером

https://hub.docker.com/_/mysql/

    $ docker pull mysql

<br/>

    $ docker run --name mysql_server -e MYSQL_ROOT_PASSWORD=P@SSW0RD -d mysql

<br/>

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
    726bc4c2433a        mysql               "/entrypoint.sh mysql"   9 seconds ago       Up 9 seconds        3306/tcp            mysql_server

<br/>

### С помощью Docker compose

    $ cd ~/

<br/>

    $ vi mysql_serv.yml

<br/>

    mysql_server:
      container_name: mysql_serv
      image: mysql:latest
      environment:
         - MYSQL_ALLOW_EMPTY_PASSWORD=yes

<br/>

Другие варианты:

    - MYSQL_ROOT_PASSWORD=P@SSW0RD
    - MYSQL_RANDOM_ROOT_PASSWORD=yes

Если задать пароль, то лично мне пришлось его вводить с кавычками. Т.е. "P@SSW0RD"
Хотел использовать пароль как P@$$W0RD, но похоже, что $$ имеет особое значение и двойной знак доллара заменяется одинарным.
Включение пароля в одинарные и двойные кавычки, ничего дало.

<br/>

    $ docker-compose -f mysql_serv.yml up -d web_server

<br/>

    $ docker-compose -f mysql_serv.yml ps

<br/>

### Работа внутри MYSQL контейнера

    $ docker exec -it mysql_serv bash

<br/>

    # mysql -u root
    mysql>
