---
layout: page
title: Docker Machine
description: Docker Machine
keywords: devops, docker, Docker Machine
permalink: /devops/containers/docker/docker-machine/
---

# Docker Machine

https://docs.docker.com/machine/install-machine/

Я пока до конца не разобрался, для чего нужена Docker Machine. И без нее все нормально работает.

Если все правильно понимаю, то для запуска Docker контейнеров с использованием драйвера virtualbox и virtualbox виртуалок. Понятно, что это нужно, когда, например приходится делать это в Windows. Но под linux не вижу особой в этом необходимости.

Делаю:  
03.04.2018

Смотрю последний релиз (сегодня это 0.14):
https://github.com/docker/machine/releases/

    # curl -L https://github.com/docker/machine/releases/download/v0.14.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine

<br/>

    # docker-machine -v
    docker-machine version 0.14.0, build 89b8332

<br/>

    #  docker-machine create --driver virtualbox docker01

<br/>

    $ docker-machine ls
    NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
    docker01   -        virtualbox   Running   tcp://192.168.99.100:2376           v18.03.0-ce

<br/>

    $ docker-machine env docker01
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.99.100:2376"
    export DOCKER_CERT_PATH="/home/marley/.docker/machine/machines/docker01"
    export DOCKER_MACHINE_NAME="docker01"
    # Run this command to configure your shell:
    # eval $(docker-machine env docker01)

<br/>

    -- Run this command to configure your shell:
    $ eval $(docker-machine env docker01)

<br/>

    -- Переключиться на активную машину. Т.е. та с которой нужно работать должна быть помечена *. Переключиться можно командой выше.

    $ docker-machine ls
    NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
    docker01   *        virtualbox   Running   tcp://192.168.99.100:2376           v18.03.0-ce

<br/>

    $ docker run -d --name nginnx --rm -p 80:80 nginx:alpine

<br/>

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED                  STATUS              PORTS                NAMES
    9ba0e3e27b77        nginx:alpine        "nginx -g 'daemon of…"   Less than a second ago   Up 5 seconds        0.0.0.0:80->80/tcp   nginnx

<br/>

    $ docker-machine  ip docker01
    192.168.99.100

<br/>
    
    $ curl -I 192.168.99.100
    HTTP/1.1 200 OK
    Server: nginx/1.13.11
    Date: Wed, 04 Apr 2018 02:14:41 GMT
    Content-Type: text/html
    Content-Length: 612
    Last-Modified: Tue, 03 Apr 2018 18:26:49 GMT
    Connection: keep-alive
    ETag: "5ac3c769-264"
    Accept-Ranges: bytes

<br/>

    # apt-get install -y jq


    $ docker-machine inspect docker01 | jq .
    {
      "Name": "docker01",
      "HostOptions": {
        "AuthOptions": {
          "StorePath": "/home/marley/.docker/machine/machines/docker01",
          "ServerCertSANs": [],
          "ClientCertPath": "/home/marley/.docker/machine/certs/cert.pem",
          "ServerKeyRemotePath": "",
          "CertDir": "/home/marley/.docker/machine/certs",
          "CaCertPath": "/home/marley/.docker/machine/certs/ca.pem",
          "CaPrivateKeyPath": "/home/marley/.docker/machine/certs/ca-key.pem",
          "CaCertRemotePath": "",
          "ServerCertPath": "/home/marley/.docker/machine/machines/docker01/server.pem",
          "ServerKeyPath": "/home/marley/.docker/machine/machines/docker01/server-key.pem",
          "ClientKeyPath": "/home/marley/.docker/machine/certs/key.pem",
          "ServerCertRemotePath": ""
        },
        "SwarmOptions": {
          "IsExperimental": false,
          "Env": null,
          "ArbitraryJoinFlags": [],
          "ArbitraryFlags": [],
          "Overcommit": 0,
          "Heartbeat": 0,
          "IsSwarm": false,
          "Address": "",
          "Discovery": "",
          "Agent": false,
          "Master": false,
          "Host": "tcp://0.0.0.0:3376",
          "Image": "swarm:latest",
          "Strategy": "spread"
        },
        "EngineOptions": {
          "InstallURL": "https://get.docker.com",
          "RegistryMirror": [],
          "TlsVerify": true,
          "SelinuxEnabled": false,
          "StorageDriver": "",
          "ArbitraryFlags": [],
          "Dns": null,
          "GraphDir": "",
          "Env": [],
          "Ipv6": false,
          "InsecureRegistry": [],
          "Labels": [],
          "LogLevel": ""
        },
        "Disk": 0,
        "Memory": 0,
        "Driver": ""
      },
      "DriverName": "virtualbox",
      "Driver": {
        "ShareFolder": "",
        "NoVTXCheck": false,
        "DNSProxy": true,
        "NoShare": false,
        "HostOnlyNoDHCP": false,
        "UIType": "headless",
        "HostOnlyPromiscMode": "deny",
        "HostOnlyNicType": "82540EM",
        "HostOnlyCIDR": "192.168.99.1/24",
        "HostDNSResolver": false,
        "Boot2DockerImportVM": "",
        "SwarmHost": "tcp://0.0.0.0:3376",
        "SwarmMaster": false,
        "StorePath": "/home/marley/.docker/machine",
        "SSHKeyPath": "/home/marley/.docker/machine/machines/docker01/id_rsa",
        "SSHPort": 38345,
        "SSHUser": "docker",
        "MachineName": "docker01",
        "IPAddress": "192.168.99.100",
        "SwarmDiscovery": "",
        "VBoxManager": {},
        "HostInterfaces": {},
        "CPU": 1,
        "Memory": 1024,
        "DiskSize": 20000,
        "NatNicType": "82540EM",
        "Boot2DockerURL": ""
      },
      "ConfigVersion": 3
    }

<br/>

    $ docker-machine ssh docker01
                            ##         .
                      ## ## ##        ==
                   ## ## ## ## ##    ===
               /"""""""""""""""""\___/ ===
          ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
               \______ o           __/
                 \    \         __/
                  \____\_______/
     _                 _   ____     _            _
    | |__   ___   ___ | |_|___ \ __| | ___   ___| | _____ _ __
    | '_ \ / _ \ / _ \| __| __) / _` |/ _ \ / __| |/ / _ \ '__|
    | |_) | (_) | (_) | |_ / __/ (_| | (_) | (__|   <  __/ |
    |_.__/ \___/ \___/ \__|_____\__,_|\___/ \___|_|\_\___|_|
    Boot2Docker version 18.03.0-ce, build HEAD : 404ee40 - Thu Mar 22 17:12:23 UTC 2018
    Docker version 18.03.0-ce, build 0520e24

<br/>

    $ docker-machine stop docker01

<br/>

    $ docker-machine rm -f docker01
