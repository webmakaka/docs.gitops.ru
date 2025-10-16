---
layout: page
title: Отправить docker image на hub.docker.com
description: Отправить docker image на hub.docker.com
keywords: devops, docker, Отправить docker image на hub.docker.com
permalink: /devops/containers/docker/basics/push-and-pull-docker-image-to-hub/
---

# Отправить docker image на hub.docker.com

Создали репо на hub.docker.com

container_id и container_name как и для image в данном случае одно и тоже.

Если нужно сделать из контейнера image, сначала нужно выполнить эту команду.

    $ docker commit <container_name> <image_name>

Или даже лучше сразу:

    $ docker commit <container_name> <your_docker_hub_login>/<image_name>:<image_version>

// При необходимости, можно поменять название image

    $ docker image tag <image_name> <your_docker_hub_login>/<image_name>:<image_version>

<br/>

### Отправка image на docker-hub

    $ docker login
    $ docker push <your_docker_hub_login>/<image_name>

<br/>

### Забрать image с ренее созданного репо.

    $ doceker pull <your_docker_hub_login>/<image_name>

<br/>

### Конкретный пример.

**Делаю 3.12.2017**<br/>
**Последний раз делал и все ок 16.04.2018**

<br/>

    Есть уже готовый image нужно его перенести на hub.docker.com <br/>
    Я зашел через веб интерфейс и добавил новый репо руками.

<br/>

    $ docker -v
    Docker version 17.03.0-ce, build 60ccb22

<br/>
    
    -- Переименовываю имидж. Чтобы контейнер на hub.docker.com начинался с моего username на этом сайте.
    $ docker tag centos6/rais:v01 marley/centos6-for-jekyll:latest
    
<br/>
    
    $ docker images
    REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
    marley/centos6-for-jekyll   latest              522e5166515e        17 minutes a

<br/>

    $ docker login
    $ docker push marley/centos6-for-jekyll

<br/>

Забрать теперь можно командой:

    $ docker pull marley/centos6-for-jekyll

<br/>

### Конкретный пример. Делал для версии (Docker version 1.9.1)

    $ docker commit nginx_server marley/nginx_server:1

    nginx_server - имя моего контейнера
    marley/nginx_server:1 - создать image со следующим именем

    $ docker images
    REPOSITORY               TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    marley/nginx_server      1                   5a6aaa885cf2        19 minutes ago      395.3 MB

<br/>

    $ docker login
    $ docker push marley/nginx_server:1

<br/>

Забрать теперь можно командой:

    $ docker pull marley/nginx_server
