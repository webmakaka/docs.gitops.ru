---
layout: page
title: Coreos Small cluster > Пример запуска coreos кластера с контейнерами docker, приложением, базой данных и прокси сервером
permalink: /devops/containers/coreos/example/02/
---


# Coreos Small cluster > Пример запуска coreos кластера с контейнерами docker, приложением, базой данных и прокси сервером

По материалам из видео курса:  

**Getting Started with CoreOS [29 Nov 2016, ENG]**

Советы по улучшению, принимаются.


<br/>

PS. Исходники с Dockerfile, можно взять здесь:

https://github.com/sysadm-ru/coreos-docker-examples/tree/master/02


Они могу понадобиться, если захочется собрать собственные контейнеры или просто посмотреть примеры.



<br/>

### Database and Web

**rethinkdb-discovery@.service**

https://github.com/sysadm-ru/coreos-docker-examples/blob/master/02/coreos-rethinkdb/rethinkdb-discovery%40.service

<br/>

    $ vi rethinkdb-discovery@.service

<br/>

    [Unit]
    Requires=docker.service
    After=docker.service

    [Service]
    EnvironmentFile=/etc/environment
    ExecStart=/bin/sh -c "while true; do etcdctl set /services/rethinkdb/${COREOS_PRIVATE_IPV4} ${COREOS_PRIVATE_IPV4} --ttl 60; sleep 45; done"
    ExecStop=/usr/bin/etcdctl rm /services/rethinkdb/${COREOS_PRIVATE_IPV4}

    [X-Fleet]
    Conflicts=rethinkdb-discovery@%i.service


<br/>

**rethinkdb@.service**

https://github.com/sysadm-ru/coreos-docker-examples/blob/master/02/coreos-rethinkdb/rethinkdb%40.service


<br/>

    $ vi rethinkdb@.service

<br/>

    [Unit]
    BindsTo=rethinkdb-discovery@%i.service
    After=rethinkdb-discovery@%i.service

    [Service]
    EnvironmentFile=/etc/environment
    TimeoutStartSec=10m
    ExecStartPre=-/usr/bin/docker kill %p-%i
    ExecStartPre=-/usr/bin/docker rm %p-%i
    ExecStartPre=-/usr/bin/mkdir -p /data/rethinkdb
    ExecStartPre=/usr/bin/docker pull rethinkdb
    ExecStart=/bin/sh -c '/usr/bin/docker run --name %p-%i  \
        -p 18080:18080               \
        -p 28015:28015               \
        -p 29015:29015               \
        -v /data/rethinkdb/:/data/                          \
        rethinkdb rethinkdb --bind all                \
        --http-port 18080                                   \
        --canonical-address ${COREOS_PRIVATE_IPV4}          \
        $(/usr/bin/etcdctl ls /services/rethinkdb |         \
            xargs -I {} /usr/bin/etcdctl get {} |           \
            sed s/^/"--join "/ | sed s/$/":29015"/ |        \
           tr "\n" " ")'
    ExecStop=/usr/bin/docker stop %p-%i
    Restart=on-failure

    [X-Fleet]
    MachineOf=rethinkdb-discovery@%i.service



<!-- <br/>

    $ fleetctl submit *

    $ fleetctl list-unit-files
    UNIT				HASH	DSTATE		STATE		TARGET
    rethinkdb-discovery@.service	683c1e5	inactive	inactive	-
    rethinkdb@.service		01c3289	inactive	inactive	- -->

<br/>

    $ fleetctl start rethinkdb-discovery@{6..7} rethinkdb@{6..7}


<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    rethinkdb-discovery@6.service	3222ccf3.../172.17.8.104	active	running
    rethinkdb-discovery@7.service	50ba5eaf.../172.17.8.106	active	running
    rethinkdb@6.service		3222ccf3.../172.17.8.104	active	running
    rethinkdb@7.service		50ba5eaf.../172.17.8.106	active	running


<br/>

    $ curl 172.17.8.106:18080


Можно подключиться браузером:  
http://172.17.8.106:18080


    $ etcdctl ls /services/rethinkdb
    /services/rethinkdb/172.17.8.104
    /services/rethinkdb/172.17.8.106

<br/>

    $ etcdctl ls /services/rethinkdb | xargs -I {} etcdctl get {}
    172.17.8.106
    172.17.8.104




<br/>

    $ etcdctl ls /services/rethinkdb | xargs -I {} etcdctl get {} | sed s/^/"--join "/ | sed s/$/":29015"/
    --join 172.17.8.104:29015
    --join 172.17.8.106:29015




<br/>

    $ etcdctl ls /services/rethinkdb | xargs -I {} etcdctl get {} | sed s/^/"--join "/ | sed s/$/":29015"/ | tr "\n" " "
    --join 172.17.8.104:29015 --join 172.17.8.106:29015


<br/>

http://172.17.8.106:4001/v2/keys/services/rethinkdb - rethinkdb api

<br/>

### WebServer


https://github.com/sysadm-ru/coreos-docker-examples/blob/master/02/coreos-gettingstarted-web/helloweb-discovery%40.service

<br/>

    $ vi helloweb-discovery@.service

<br/>

    [Unit]
    Requires=docker.service
    After=docker.service

    [Service]
    EnvironmentFile=/etc/environment
    ExecStart=/bin/sh -c "while true; do etcdctl set /services/web/${COREOS_PRIVATE_IPV4} ${COREOS_PRIVATE_IPV4} --ttl 60; sleep 45; done"
    ExecStop=/usr/bin/etcdctl rm /services/web/${COREOS_PRIVATE_IPV4}

    [X-Fleet]
    Conflicts=helloweb-discovery@%i.service


<br/>

https://github.com/sysadm-ru/coreos-docker-examples/blob/master/02/coreos-gettingstarted-web/helloweb%40.service

    $ vi helloweb@.service

<br/>

    [Unit]
    BindsTo=helloweb-discovery@%i.service
    After=helloweb-discovery@%i.service

    [Service]
    EnvironmentFile=/etc/environment
    TimeoutStartSec=10m
    ExecStartPre=-/usr/bin/docker kill %p-%i
    ExecStartPre=-/usr/bin/docker rm %p-%i
    ExecStartPre=/usr/bin/docker pull marley/coreos-gettingstarted-web
    ExecStart=/bin/sh -c '/usr/bin/docker run --name %p-%i  \
        -p 8080:8080                                        \
        -e COREOS_PRIVATE_IPV4=${COREOS_PRIVATE_IPV4}       \
        marley/coreos-gettingstarted-web'
    ExecStop=/usr/bin/docker stop %p-%i
    Restart=always

    [X-Fleet]
    MachineOf=helloweb-discovery@%i.service


<br/>

    $ fleetctl start helloweb-discovery@{3..5} helloweb@{3..5}

<br/>

// следим за ходом выполнения

    $ fleetctl journal -f --lines=100 helloweb@3.service

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    helloweb-discovery@3.service	6d8e85f3.../172.17.8.101	active	running
    helloweb-discovery@4.service	8a88c8ac.../172.17.8.107	active	running
    helloweb-discovery@5.service	b386939f.../172.17.8.102	active	running
    helloweb@3.service		6d8e85f3.../172.17.8.101	active	running
    helloweb@4.service		8a88c8ac.../172.17.8.107	active	running
    helloweb@5.service		b386939f.../172.17.8.102	active	running
    rethinkdb-discovery@6.service	3222ccf3.../172.17.8.104	active	running
    rethinkdb-discovery@7.service	50ba5eaf.../172.17.8.106	active	running
    rethinkdb@6.service		3222ccf3.../172.17.8.104	active	running
    rethinkdb@7.service		50ba5eaf.../172.17.8.106	active	running


<br/>


**Подключился к приложению:**

    $ curl http://172.17.8.101:8080/greeting
    "Hello, User! From 172.17.8.101"


<br/>

### Load Balancing

https://github.com/sysadm-ru/coreos-docker-examples/blob/master/02/coreos-gettingstarted-lb/hellolb%40.service

    $ vi hellolb@.service

<br/>

    [Unit]
    Requires=docker.service
    After=docker.service

    [Service]
    EnvironmentFile=/etc/environment
    TimeoutStartSec=10m
    ExecStartPre=-/usr/bin/docker kill %p-%i
    ExecStartPre=-/usr/bin/docker rm %p-%i
    ExecStartPre=/usr/bin/docker pull marley/coreos-gettingstarted-lb
    ExecStart=/bin/sh -c '/usr/bin/docker run --name %p-%i  \
        -p 8888:8888                                        \
        -e COREOS_PRIVATE_IPV4=${COREOS_PRIVATE_IPV4}       \
        marley/coreos-gettingstarted-lb'
    ExecStop=/usr/bin/docker stop %p-%i
    Restart=always

    [X-Fleet]
    Conflicts=hellolb@%i.service


<br/>

    $ fleetctl start hellolb@{1..2}


// следим за ходом выполнения

    $ fleetctl journal -f --lines=100 hellolb@1.service

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    hellolb@1.service		c983059a.../172.17.8.103	active	running
    hellolb@2.service		d65c18f4.../172.17.8.105	active	running
    helloweb-discovery@3.service	6d8e85f3.../172.17.8.101	active	running
    helloweb-discovery@4.service	8a88c8ac.../172.17.8.107	active	running
    helloweb-discovery@5.service	b386939f.../172.17.8.102	active	running
    helloweb@3.service		6d8e85f3.../172.17.8.101	active	running
    helloweb@4.service		8a88c8ac.../172.17.8.107	active	running
    helloweb@5.service		b386939f.../172.17.8.102	active	running
    rethinkdb-discovery@6.service	3222ccf3.../172.17.8.104	active	running
    rethinkdb-discovery@7.service	50ba5eaf.../172.17.8.106	active	running
    rethinkdb@6.service		3222ccf3.../172.17.8.104	active	running
    rethinkdb@7.service		50ba5eaf.../172.17.8.106	active	running


<br/>

    $ curl http://172.17.8.103:8888/greeting
    "Hello, User! From 172.17.8.107"

    core@core-01 ~ $ curl http://172.17.8.103:8888/greeting
    "Hello, User! From 172.17.8.101"

    core@core-01 ~ $ curl http://172.17.8.103:8888/greeting
    "Hello, User! From 172.17.8.102"core@core-01 ~ $

<br/>

Меняется веб сервер к которому подключаемся.


<br/>

### Посмотрим что внутри Load Balancer

    $ fleetctl ssh hellolb@1

<br/>

    $ docker exec -it hellolb-1 bash

<br/>

    # cat /opt/lb/nginx.conf

<br/>

    events {
        worker_connections 4096;
    }

    http {
        upstream backend {
            server 172.17.8.107:8080;
            server 172.17.8.101:8080;
            server 172.17.8.102:8080;
        }
        server {
            listen 8888;
            location / {
                proxy_pass http://backend;
            }
        }
    }
