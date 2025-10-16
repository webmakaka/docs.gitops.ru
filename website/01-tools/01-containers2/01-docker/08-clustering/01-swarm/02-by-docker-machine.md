---
layout: page
title: Docker Swarm - кластер с использованием docker-machine
description: Docker Swarm - кластер с использованием docker-machine
keywords: devops, docker, Docker Swarm - кластер с использованием docker-machine
permalink: /devops/containers/docker/clustering/swarm/by-docker-machine/
---

# Docker Swarm - кластер с использованием docker-machine (без сохранения данных после перезагрузки)

Не рекомендую делать так.  
При остановке сервера базы данных, данные пропадают.

По материалам видеокурса: Projects-in-Docker

Делаю в конце апреля 2018

Разворачиваю в swarm вот это приложение:  
https://github.com/webmakaka/Projects-in-Docker

    $ mkdir ~/docker-swarm-scripts
    $ cd ~/docker-swarm-scripts

<br/>

    $ vi create-machine.sh

<br/>

    #!/bin/bash

    for i in 1 2 3; do
        docker-machine create -d virtualbox swarm-$i
    done

<br/>

    $ vi destroy-machine.sh

<br/>

    #!/bin/bash

    for i in 1 2 3; do
        docker-machine rm -f swarm-$i
    done

<br/>

    $ source ./destroy-machine.sh

    $ docker-machine ls

    никаких машин не возвращает


    $ source ./create-machine.sh


    $ eval $(docker-machine env swarm-1)

    $ docker-machine ls
    NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
    swarm-1   *        virtualbox   Running   tcp://192.168.99.100:2376           v18.04.0-ce
    swarm-2   -        virtualbox   Running   tcp://192.168.99.101:2376           v18.04.0-ce
    swarm-3   -        virtualbox   Running   tcp://192.168.99.102:2376           v18.04.0-ce

<br/>
    
    $ docker swarm init --advertise-addr $(docker-machine ip swarm-1)

    $ docker swarm join-token manager

    $ docker swarm join-token worker

    $ JOIN_TOKEN=$(docker swarm join-token -q worker)
    $ echo $JOIN_TOKEN

    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    muvi5yxed9q4iieutf96l58ic *   swarm-1             Ready               Active              Leader              18.04.0-ce



    $ eval $(docker-machine env swarm-2)

    $ docker swarm join --token $JOIN_TOKEN \
    --advertise-addr $(docker-machine ip swarm-2) \
    $(docker-machine ip swarm-1):2377


    $ eval $(docker-machine env swarm-3)

    $ docker swarm join --token $JOIN_TOKEN \
    --advertise-addr $(docker-machine ip swarm-3) \
    $(docker-machine ip swarm-1):2377



    $ eval $(docker-machine env swarm-1)

    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    muvi5yxed9q4iieutf96l58ic *   swarm-1             Ready               Active              Leader              18.04.0-ce
    ifswsuffyd7y6x6vhqv0ashm3     swarm-2             Ready               Active                                  18.04.0-ce
    pboiazm2mfrfdm9b02o5iu836     swarm-3             Ready               Active                                  18.04.0-ce

<br/>

### Сеть

<br/>

    $ docker network create -d overlay blog_network

    $ docker network ls
    p7pw78didto8        blog_network        overlay             swarm

<br/>

### Подготовка имиджей

    $ cd mydb
    $ docker build -t marley/mydb .

    $ cd myapp/
    $ docker build -t marley/myapp .

    $ cd mywebserver/
    $ docker build -t marley/mywebserver --build-arg PASSWORD=pass123 .

Чтобы запустить контейнер в swarm, его нужно куда-то положить. То что он лежит локально на хост машине, ничего незначит. Виртуалки не знают ничего об этом. Я решил, что проще всего положить их на docker hub.

Захожу на docker hub, создаю репо. (мб. уже и не нужно создавать в веб интерфейсе. хз)

    $ docker login
    $ docker push marley/mydb
    $ docker push marley/myapp
    $ docker push marley/mywebserver

<br/>

### Запуск сервисов

    $ docker service create -d \
    --name db_server \
    --replicas 1 \
    --network blog_network \
    --mount type=volume,source=database_volume,destination=/data/db \
    marley/mydb

<br/>
    
    $ docker service create \
    --name app_server \
    --replicas 3 \
    --network blog_network \
    marley/myapp
    
<br/>
    
    $ docker service create -d \
    --name=webserver \
    --replicas 3 \
    --network blog_network \
    --publish=8080:80/tcp \
    marley/mywebserver

<br/>
    
    $ docker service ls
    ID                  NAME                MODE                REPLICAS            IMAGE                       PORTS
    r6ppou1bqmg0        app_server          replicated          3/3                 marley/myapp:latest         
    417mscwvu3oj        db_server           replicated          1/1                 marley/mydb:latest          
    oatk2lqmynxa        webserver           replicated          3/3                 marley/mywebserver:latest   *:8080->80/tcp

<br/>

    $ docker container ls
    CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS               NAMES
    1ee8c2a26dd7        marley/mywebserver:latest   "nginx -g 'daemon of…"   2 minutes ago       Up 3 minutes        80/tcp              webserver.3.gawovk8leaow20ru9qywplunc
    65d5f241a953        marley/myapp:latest         "npm start"              3 minutes ago       Up 3 minutes        3000/tcp            app_server.3.iphvuq3k37oh6oa3yypou4xio
    582cc62298b4        marley/mydb:latest          "docker-entrypoint.s…"   16 minutes ago      Up 17 minutes       27017/tcp           db_server.1.kjwzu91ibh87f1rppfpi4j7qr


    $ curl -I http://$(docker-machine ip swarm-1):8080
    OK

    $ echo http://$(docker-machine ip swarm-1):8080
    http://192.168.99.100:8080

<br/>
    
    http://192.168.99.100:8080/create.html#/
    
    login: user
    pass: pass123

<br/>

### Тоже самое с помощью yml файла

    $ vi blog_swarm.yml

    version: "3"
    services:
      db_server:
        image: marley/mydb
        networks:
          - blog_network
        deploy:
          replicas: 1
          restart_policy:
            condition: on-failure
        volumes:
          - database_volume:/data/db

      app_server:
        image: marley/myapp
        networks:
          - blog_network
        depends_on:
          - db_server
        deploy:
          replicas: 3
          restart_policy:
            condition: on-failure

      webserver:
        image: marley/mywebserver
        networks:
          - blog_network
        ports:
          - 8080:80
        depends_on:
          - app_server
        deploy:
          replicas: 3
          restart_policy:
            condition: on-failure
    networks:
      blog_network:

    volumes:
      database_volume:

<br/>

    $ docker stack deploy -c blog_swarm.yml blog_swarm
