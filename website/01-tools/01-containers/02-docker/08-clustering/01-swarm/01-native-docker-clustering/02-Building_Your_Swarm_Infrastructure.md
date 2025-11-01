---
layout: page
title: Native Docker Clustering > building your swarm infrastructure
description: Native Docker Clustering > building your swarm infrastructure
keywords: devops, containers, docker, clustering, swarm, swarm infrastructure
permalink: /devops/containers/docker/clustering/swarm/native-docker-clustering/building-your-swarm-infrastructure/
---

# Docker Swarm: Native Docker Clustering [2016, ENG] > Module 4: Building your Swarm Infrastructure

<br/>

![Native Docker Clustering](/img/devops/containers//docker/clustering/swarm/native-docker-clustering/pic2.png 'Native Docker Clustering'){: .center-image }

<br/>

    $ vagrant up

<br/>

**Инсталляция python 2 в coreos**

<!-- https://github.com/sysadm-ru/python-on-coreos/blob/master/install-python-on-coreos.sh -->

172.17.0.1 - ip адрес docker интерфейса на хостовой машине.

<br/>

### CONSUL BUILD COMMANDS

<br/>

**CORE 01**

    $ vagrant ssh core-01

    $ docker run --restart=unless-stopped -d -h consul1 --name consul1 -v /mnt:/data \
    -p 10.0.11.5:8300:8300 \
    -p 10.0.11.5:8301:8301 \
    -p 10.0.11.5:8301:8301/udp \
    -p 10.0.11.5:8302:8302 \
    -p 10.0.11.5:8302:8302/udp \
    -p 10.0.11.5:8400:8400 \
    -p 10.0.11.5:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul -server -advertise 10.0.11.5 -bootstrap-expect 3

<br/>

**CORE 02**

    $ vagrant ssh core-02

    $ docker run --restart=unless-stopped -d -h consul2 --name consul2 -v /mnt:/data  \
    -p 10.0.12.5:8300:8300 \
    -p 10.0.12.5:8301:8301 \
    -p 10.0.12.5:8301:8301/udp \
    -p 10.0.12.5:8302:8302 \
    -p 10.0.12.5:8302:8302/udp \
    -p 10.0.12.5:8400:8400 \
    -p 10.0.12.5:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul -server -advertise 10.0.12.5 -join 10.0.11.5

<br/>

**CORE 03**

    $ vagrant ssh core-03

    $ docker run --restart=unless-stopped -d -h consul3 --name consul3 -v /mnt:/data  \
    -p 10.0.13.5:8300:8300 \
    -p 10.0.13.5:8301:8301 \
    -p 10.0.13.5:8301:8301/udp \
    -p 10.0.13.5:8302:8302 \
    -p 10.0.13.5:8302:8302/udp \
    -p 10.0.13.5:8400:8400 \
    -p 10.0.13.5:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul -server -advertise 10.0.13.5 -join 10.0.11.5

<br/>

**CORE 01**

<br/>

    $ docker exec -it consul1 bash

<br/>

    bash-4.3# consul members
    Node     Address         Status  Type    Build  Protocol  DC
    consul1  10.0.11.5:8301  alive   server  0.5.2  2         dc1
    consul2  10.0.12.5:8301  alive   server  0.5.2  2         dc1
    consul3  10.0.13.5:8301  alive   server  0.5.2  2         dc1

<br/>

### SWARM MANAGER BUILD COMMANDS

    **core 01**

    $ docker run --restart=unless-stopped -h mgr1 --name mgr1 -d -p 3375:2375 swarm manage --replication --advertise 10.0.11.5:3375 consul://10.0.11.5:8500/


    **core 02**

    $ docker run --restart=unless-stopped -h mgr2 --name mgr2 -d -p 3375:2375 swarm manage --replication --advertise 10.0.12.5:3375 consul://10.0.12.5:8500/


    **core 03**

    $ docker run --restart=unless-stopped -h mgr3 --name mgr3 -d -p 3375:2375 swarm manage --replication --advertise 10.0.13.5:3375 consul://10.0.13.5:8500/

<br/>

    **core 01**

    $ docker logs mgr1
    time="2017-01-31T21:01:29Z" level=info msg="Initializing discovery without TLS"
    time="2017-01-31T21:01:29Z" level=info msg="Listening for HTTP" addr=":2375" proto=tcp
    time="2017-01-31T21:01:29Z" level=info msg="Leader Election: Cluster leadership lost"
    time="2017-01-31T21:01:29Z" level=info msg="Leader Election: Cluster leadership acquired"

<br/>

### CONSUL CLIENT BUILDS ON NODES 1-3

    $ vagrant ssh core-04

    **core 04**

    $ docker run --restart=unless-stopped -d -h consul-agt1 --name consul-agt1 \
    -p 8300:8300 \
    -p 8301:8301 -p 8301:8301/udp \
    -p 8302:8302 -p 8302:8302/udp \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:8600/udp \
    progrium/consul -rejoin -advertise 10.0.14.5 -join 10.0.11.5

<br/>

    $ vagrant ssh core-05

    **core 05**

    $ docker run --restart=unless-stopped -d -h consul-agt2 --name consul-agt2 \
    -p 8300:8300 \
    -p 8301:8301 -p 8301:8301/udp \
    -p 8302:8302 -p 8302:8302/udp \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:8600/udp \
    progrium/consul -rejoin -advertise 10.0.15.5 -join 10.0.11.5

<br/>

    $ vagrant ssh core-06

    **core 06**

    $ docker run --restart=unless-stopped -d -h consul-agt3 --name consul-agt3 \
    -p 8300:8300 \
    -p 8301:8301 -p 8301:8301/udp \
    -p 8302:8302 -p 8302:8302/udp \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:8600/udp \
    progrium/consul -rejoin -advertise 10.0.16.5 -join 10.0.11.5

<br/>

### SWARM JOIN COMMANDS TO JOIN NODES TO THE CLUSTER

    **core 04**

    $ docker run -d swarm join --advertise=10.0.14.5:2375 consul://10.0.14.5:8500/


    **core 05**

    $ docker run -d swarm join --advertise=10.0.15.5:2375 consul://10.0.15.5:8500/


    **core 06**

    $ docker run -d swarm join --advertise=10.0.16.5:2375 consul://10.0.16.5:8500/

<br/>

**CORE 01**

<br/>

    $ docker exec -it consul1 bash

<br/>

    bash-4.3# consul members
    Node         Address         Status  Type    Build  Protocol  DC
    consul-agt1  10.0.14.5:8301  alive   client  0.5.2  2         dc1
    consul-agt2  10.0.15.5:8301  alive   client  0.5.2  2         dc1
    consul-agt3  10.0.16.5:8301  alive   client  0.5.2  2         dc1
    consul1      10.0.11.5:8301  alive   server  0.5.2  2         dc1
    consul2      10.0.12.5:8301  alive   server  0.5.2  2         dc1
    consul3      10.0.13.5:8301  alive   server  0.5.2  2         dc1

<br/>

    $ curl http://10.0.13.5:8500/v1/catalog/nodes | python -m json.tool


    [
        {
            "Address": "10.0.14.5",
            "Node": "consul-agt1"
        },
        {
            "Address": "10.0.15.5",
            "Node": "consul-agt2"
        },
        {
            "Address": "10.0.16.5",
            "Node": "consul-agt3"
        },
        {
            "Address": "10.0.11.5",
            "Node": "consul1"
        },
        {
            "Address": "10.0.12.5",
            "Node": "consul2"
        },
        {
            "Address": "10.0.13.5",
            "Node": "consul3"
        }
    ]

<br/>

**На всех:**

    $ docker run -d --name registrator -h registrator -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://10.0.11.5:8500

<br/>

    $ curl http://10.0.13.5:8500/v1/catalog/services | python -m json.tool


    {
        "consul": [],
        "consul-53": [
            "udp"
        ],
        "consul-8300": [],
        "consul-8301": [
            "udp"
        ],
        "consul-8302": [
            "udp"
        ],
        "consul-8400": [],
        "consul-8500": [],
        "consul-8600": [
            "udp"
        ],
        "swarm": []
    }

<br/>

    $ curl http://10.0.13.5:8500/v1/catalog/service/swarm | python -m json.tool

    [
        {
            "Address": "10.0.11.5",
            "Node": "consul1",
            "ServiceAddress": "",
            "ServiceID": "registrator:mgr1:2375",
            "ServiceName": "swarm",
            "ServicePort": 3375,
            "ServiceTags": null
        },
        {
            "Address": "10.0.11.5",
            "Node": "consul1",
            "ServiceAddress": "",
            "ServiceID": "registrator:mgr2:2375",
            "ServiceName": "swarm",
            "ServicePort": 3375,
            "ServiceTags": null
        },
        {
            "Address": "10.0.11.5",
            "Node": "consul1",
            "ServiceAddress": "",
            "ServiceID": "registrator:mgr3:2375",
            "ServiceName": "swarm",
            "ServicePort": 3375,
            "ServiceTags": null
        }
    ]

<br/>

**CORE 04**

    $ docker run -d --name web1 -p 80:80 nginx

<br/>

**CORE 01**

    $ curl http://10.0.13.5:8500/v1/catalog/services | python -m json.tool

    {
        "consul": [],
        "consul-53": [
            "udp"
        ],
        "consul-8300": [],
        "consul-8301": [
            "udp"
        ],
        "consul-8302": [
            "udp"
        ],
        "consul-8400": [],
        "consul-8500": [],
        "consul-8600": [
            "udp"
        ],
        "nginx-80": [],
        "swarm": []
    }

Чего сделали? Чего добились? ХЗ  
Чего с этим дерьмом делать то?

Наверное нужно настроить security, потом подключиться клиентом к ноде менеджеру и тогда будет все работать.

<br/>

    $ docker run swarm list consul://10.0.11.5
    2017/02/05 06:36:23 Get http://10.0.11.5/v1/kv/docker/swarm/nodes?consistent=: dial tcp 10.0.11.5:80: getsockopt: connection refused
    time="2017-02-05T06:36:23Z" level=info msg="Initializing discovery without TLS"
