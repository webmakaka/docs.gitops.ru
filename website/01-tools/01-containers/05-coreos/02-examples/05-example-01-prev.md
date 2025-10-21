---
layout: page
title: Пример запуска coreos кластера с контейнерами docker, приложением, базой данных и прокси сервером
permalink: /devops/containers/coreos/example/01/prev/
---

# Пример запуска coreos кластера с контейнерами docker, приложением, базой данных и прокси сервером

<br/>

PS. Исходники с Dockerfile, можно взять здесь:

https://bitbucket.org/sysadm-ru/introduction_to_coreos

Они могу понадобиться, если захочется собрать собственные контейнеры или просто посмотреть примеры.

<br/>

**Для запуска примеров нужно:**

1. Установить virtualbox
2. Установить vagrant

<br/>

### Vagrantfile и user-data

Скопировать файлы:

https://bitbucket.org/sysadm-ru/native-docker-clustering

<br/>

    $ cd ~
    $ git clone https://bitbucket.org/sysadm-ru/native-docker-clustering
    $ cd Native-Docker-Clustering

<br/>

Сгенерировать ключ:

https://discovery.etcd.io/new?size=7

    $ vi user-data

Заменить сгенерированным ключом.

    discovery: https://discovery.etcd.io/89e341b6012e47d7e6654eea7b882418

<br/>

    $ vagrant box update

<br/>

    $ vagrant up

<br/>

// Чтобы можно было по ssh ходить между узлами без пароля

$ ssh-add ~/.vagrant.d/insecure_private_key

<br/>

    $ vagrant status
    Current machine states:

    core-01                   running (virtualbox)
    core-02                   running (virtualbox)
    core-03                   running (virtualbox)
    core-04                   running (virtualbox)
    core-05                   running (virtualbox)
    core-06                   running (virtualbox)
    core-07                   running (virtualbox)

<br/>

    $ vagrant ssh core-01

<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    047ef507...	10.0.11.5	-
    104a924a...	10.0.12.5	-
    2ccc7711...	10.0.14.5	-
    3c89f9a9...	10.0.15.5	-
    8df586c8...	10.0.16.5	-
    b9048ab8...	10.0.13.5	-

<br/>

### Базы данных

    $ vi rethinkdb-announce@.service

<br/>

    [Unit]
    Description=Announce RethinkDB %i service

    [Service]
    EnvironmentFile=/etc/environment
    ExecStart=/bin/sh -c "while true; do etcdctl set /services/rethinkdb/rethinkdb-%i ${COREOS_PUBLIC_IPV4} --ttl 60; sleep 45; done"
    ExecStop=/usr/bin/etcdctl rm /services/rethinkdb/rethinkdb-%i

    [X-Fleet]
    X-Conflicts=rethinkdb-announce@*.service

<br/>

    $ vi rethinkdb@.service

<br/>

    [Unit]
    Description=RethinkDB %i service
    After=docker.service
    BindsTo=rethinkdb-announce@%i.service

    [Service]
    EnvironmentFile=/etc/environment
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill rethinkdb-%i
    ExecStartPre=-/usr/bin/docker rm rethinkdb-%i
    ExecStartPre=-/usr/bin/mkdir -p /home/core/docker-volumes/rethinkdb
    ExecStartPre=/usr/bin/docker pull marley/coreos-rethinkdb:latest
    ExecStart=/bin/sh -c '/usr/bin/docker run --name rethinkdb-%i   \
     -p ${COREOS_PUBLIC_IPV4}:8080:8080                        \
     -p ${COREOS_PUBLIC_IPV4}:28015:28015                      \
     -p ${COREOS_PUBLIC_IPV4}:29015:29015                      \
     marley/coreos-rethinkdb:latest rethinkdb --bind all \
     --canonical-address ${COREOS_PUBLIC_IPV4}                 \
     $(/usr/bin/etcdctl ls /services/rethinkdb |               \
         xargs -I {} /usr/bin/etcdctl get {} |                 \
         sed s/^/"--join "/ | sed s/$/":29015"/ |              \
         tr "\n" " ")'

    ExecStop=/usr/bin/docker stop rethinkdb-%i

    [X-Fleet]
    X-ConditionMachineOf=rethinkdb-announce@%i.service

<br/>

**Что возвращается:**

    $ cat /etc/environment
    COREOS_PUBLIC_IPV4=10.0.11.5
    COREOS_PRIVATE_IPV4=10.0.11.5

<br/>

    $ echo $(/usr/bin/etcdctl ls /services/rethinkdb |               \
    >          xargs -I {} /usr/bin/etcdctl get {} |                 \
    >          sed s/^/"--join "/ | sed s/$/":29015"/ |              \
    >          tr "\n" " ")
    --join 10.0.13.5:29015 --join 10.0.15.5:29015

<br/>

    $ fleetctl submit *

    $ fleetctl list-unit-files
    UNIT				HASH	DSTATE		STATE		TARGET
    rethinkdb-announce@.service	3f7611a	inactive	inactive	-
    rethinkdb@.service		96c6e09	inactive	inactive	-

<br/>

    $ fleetctl start rethinkdb@6 rethinkdb-announce@6
    $ fleetctl start rethinkdb@7 rethinkdb-announce@7

<br/>

    $ fleetctl list-units
    UNIT				MACHINE			ACTIVE	SUB
    rethinkdb-announce@6.service	09e7fca1.../10.0.13.5	active	running
    rethinkdb-announce@7.service	16d2848f.../10.0.15.5	active	running
    rethinkdb@6.service		09e7fca1.../10.0.13.5	active	running
    rethinkdb@7.service		16d2848f.../10.0.15.5	active	running

<br/>

    $ curl 10.0.15.5:8080

Все ок. получил контент от сервера баз данных.

<br/>

![coreos cluster example](/img/devops/containers/coreos/example/01/pic1.png 'coreos cluster example'){: .center-image }

<br/>

    $ etcdctl ls --recursive

    ***

    /services
    /services/rethinkdb
    /services/rethinkdb/rethinkdb-7
    /services/rethinkdb/rethinkdb-6

<br/>

### Web Сервера

    $ etcdctl get /services/rethinkdb/rethinkdb-6
    10.0.13.5

    $ etcdctl get /services/rethinkdb/rethinkdb-7
    10.0.15.5

<br/>

    $ cd /tmp/
    $ git clone --depth=1 https://github.com/sysadm-ru/Introduction_To_CoreOS
    $ cd Introduction_To_CoreOS/Chapter5/todo-angular-express/

<br/>

    $ vi config.js

'172.17.8.101' меняю на '10.0.15.5'

<br/>

10.0.15.5 - любой coreos хост с etcd, который предоставит информацию о подключении к базе. Разумеется, лучше потом какую-нибудь DNS запись для этого использовать.

<br/>

    $ docker build --rm -t marley/coreos-nodejs-web-app .

<br/>

    $ docker images
    REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
    marley/coreos-app         latest              54533dca8c65        8 minutes ago       736.1 MB
    marley/coreos-rethinkdb   latest              ee254ccee514        8 weeks ago         181.8 MB
    iojs                      2.2                 2a1868f3dfd8        20 months ago       703.8 MB

<br/>

    $ docker login

Ранее в веб интерфейсе создано репо.

    $ docker push marley/coreos-nodejs-web-app

<br/>

    $ cd ~

<br/>

    $ vi todo@.service

<br/>

    [Unit]
    Description=ToDo Service

    Requires=docker.service
    Requires=todo-sk@%i.service
    After=docker.service

    [Service]
    EnvironmentFile=/etc/environment
    User=core

    Restart=always
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill %p-%i
    ExecStartPre=-/usr/bin/docker rm %p-%i
    ExecStartPre=/usr/bin/docker pull marley/coreos-nodejs-web-app
    ExecStart=/usr/bin/docker run --name %p-%i \
          -h %H \
          -p ${COREOS_PUBLIC_IPV4}:3000:3000 \
          -e INSTANCE=%p-%i \
          marley/coreos-nodejs-web-app
    ExecStop=-/usr/bin/docker kill %p-%i
    ExecStop=-/usr/bin/docker rm %p-%i

    [X-Fleet]
    Conflicts=todo@*.service

<br/>

    $ vi todo-sk@.service

<br/>

    [Unit]
    Description=ToDo Sidekick
    Requires=todo@%i.service

    After=docker.service
    After=todo@%i.service
    BindsTo=todo@%i.service

    [Service]
    EnvironmentFile=/etc/environment
    User=core
    Restart=always
    TimeoutStartSec=0
    ExecStart=/bin/bash -c '\
    while true; do \
     port=$(docker inspect --format=\'{{(index (index .NetworkSettings.Ports \"3000/tcp\") 0).HostPort}}\' todo-%i); \
     curl -sf ${COREOS_PUBLIC_IPV4}:$port/ > /dev/null 2>&1; \
     if [ $? -eq 0 ]; then \
       etcdctl set /services/todo/todo-%i ${COREOS_PUBLIC_IPV4}:$port --ttl 10; \
     else \
       etcdctl rm /services/todo/todo-%i; \
     fi; \
     sleep 5; \
     done'

    ExecStop=/usr/bin/etcdctl rm /services/todo/todo-%i

    [X-Fleet]
    MachineOf=todo@%i.service

<br/>

Следующая команда должна будет возвращать порт на котором работает вебсервер.

    $ docker inspect --format="{{(index (index .NetworkSettings.Ports \"3000/tcp\") 0).HostPort}}" todo-4
    3000

<br/>

    $ fleetctl submit todo*

<br/>

    $ fleetctl list-unit-files
    UNIT				HASH	DSTATE		STATE		TARGET
    rethinkdb-announce@.service	3f7611a	inactive	inactive	-
    rethinkdb-announce@6.service	3f7611a	launched	launched	09e7fca1.../10.0.13.5
    rethinkdb-announce@7.service	3f7611a	launched	launched	16d2848f.../10.0.15.5
    rethinkdb@.service		96c6e09	inactive	inactive	-
    rethinkdb@6.service		96c6e09	launched	launched	09e7fca1.../10.0.13.5
    rethinkdb@7.service		96c6e09	launched	launched	16d2848f.../10.0.15.5
    todo-sk@.service		64bb9b6	inactive	inactive	-
    todo@.service			3dc7e5b	inactive	inactive	-

<br/>

    $ fleetctl start todo@{3..5} todo-sk@{3..5}

<br/>

    $ fleetctl list-units
    UNIT				MACHINE			ACTIVE	SUB
    rethinkdb-announce@6.service	09e7fca1.../10.0.13.5	active	running
    rethinkdb-announce@7.service	16d2848f.../10.0.15.5	active	running
    rethinkdb@6.service		09e7fca1.../10.0.13.5	active	running
    rethinkdb@7.service		16d2848f.../10.0.15.5	active	running
    todo-sk@3.service		72720a60.../10.0.17.5	active	running
    todo-sk@4.service		56b7dcad.../10.0.14.5	active	running
    todo-sk@5.service		b420d775.../10.0.11.5	active	running
    todo@3.service			72720a60.../10.0.17.5	active	running
    todo@4.service			56b7dcad.../10.0.14.5	active	running
    todo@5.service			b420d775.../10.0.11.5	active	running

<br/>

    $ curl 10.0.17.5:3000

Все ок. получил контент приложения от вебсервера.

<br/>

    $ etcdctl ls --recursive

    ***

    /services
    /services/rethinkdb
    /services/rethinkdb/rethinkdb-6
    /services/rethinkdb/rethinkdb-7
    /services/todo
    /services/todo/todo-3
    /services/todo/todo-4
    /services/todo/todo-5

<br/>

![coreos cluster example](/img/devops/containers/coreos/example/01/pic2.png 'coreos cluster example'){: .center-image }

<br/>

**На самом деле, с первого раза ничего не запустилось**

Пришлось искать что это за виртуалка на которой располагается данный сервис.

Номер, виртуалки не совпадал.

    // логи

    $ fleetctl journal -f --lines=50 todo@3
    $ fleetctl journal -f --lines=50 todo-sk@3

Пришлось не только перестартовывать, но и удалять конфиги, удалять docker images руками.

<br/>

    $ fleetctl stop todo@{3..5} todo-sk@{3..5}
    $ fleetctl unload todo@{3..5} todo-sk@{3..5}
    $ fleetctl destroy todo@{3..5} todo-sk@{3..5}
    $ fleetctl destroy todo@.service
    $ fleetctl destroy todo-sk@.service

И далее повторять все с начала.

<br/>

### Proxy Nginx

    $ cd /tmp/Introduction_To_CoreOS/Chapter5/nginx-proxy/

<br/>

    $ vi confd-watch

заменил

    export HOST_IP=${HOST_IP:-172.17.8.101}

на

    export HOST_IP=${HOST_IP:-10.0.15.5}

10.0.15.5 - любой coreos хост с etcd

<br/>

    $ docker build --rm -t marley/coreos-nginx .

<br/>

    $ docker images
    REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
    marley/coreos-nginx       latest              957faace8b64        11 seconds ago      159.3 MB
    marley/coreos-app         latest              54533dca8c65        41 minutes ago      736.1 MB
    marley/coreos-rethinkdb   latest              ee254ccee514        8 weeks ago         181.8 MB
    nginx                     1.9.3               ea4b88a656c9        19 months ago       132.8 MB
    iojs                      2.2                 2a1868f3dfd8        20 months ago       703.8 MB

<br/>

    $ docker login

<br/>

Ранее в веб интерфейсе создано репо.

    $ docker push marley/coreos-nginx

<br/>

    $ cd ~

<br/>

    $ vi nginx.service

<br/>

    [Unit]
    Description=Nginx Proxy

    Requires=docker.service
    After=docker.service
    After=etcd2.service
    Requires=etcd2.service

    [Service]
    EnvironmentFile=/etc/environment
    User=core

    Restart=always
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill %p-%i
    ExecStartPre=-/usr/bin/docker rm %p-%i
    ExecStartPre=-/usr/bin/etcdctl mkdir /services/todo
    ExecStartPre=-/usr/bin/docker pull marley/coreos-nginx
    ExecStart=/usr/bin/docker run --name %p-%i \
          -h %H \
          -p ${COREOS_PUBLIC_IP}:80:80 \
          marley/coreos-nginx
    ExecStop=-/usr/bin/docker kill %p-%i
    ExecStop=-/usr/bin/docker rm %p-%i

    [X-Fleet]
    Global=true

<br/>

    $ fleetctl submit nginx.service

<br/>

    $ fleetctl list-unit-files
    UNIT				HASH	DSTATE		STATE		TARGET
    nginx.service			111d636	inactive	-		global
    rethinkdb-announce@.service	3f7611a	inactive	inactive	-
    rethinkdb-announce@6.service	3f7611a	launched	launched	09e7fca1.../10.0.13.5
    rethinkdb-announce@7.service	3f7611a	launched	launched	16d2848f.../10.0.15.5
    rethinkdb@.service		96c6e09	inactive	inactive	-
    rethinkdb@6.service		96c6e09	launched	launched	09e7fca1.../10.0.13.5
    rethinkdb@7.service		96c6e09	launched	launched	16d2848f.../10.0.15.5
    todo-sk@.service		e8b8fa1	inactive	inactive	-
    todo-sk@3.service		e8b8fa1	launched	launched	b420d775.../10.0.11.5
    todo-sk@4.service		e8b8fa1	launched	launched	72720a60.../10.0.17.5
    todo-sk@5.service		e8b8fa1	launched	launched	56b7dcad.../10.0.14.5
    todo@.service			b6473ba	inactive	inactive	-
    todo@3.service			b6473ba	launched	launched	b420d775.../10.0.11.5
    todo@4.service			b6473ba	launched	launched	72720a60.../10.0.17.5
    todo@5.service			b6473ba	launched	launched	56b7dcad.../10.0.14.5

<br/>

    $ fleetctl start nginx.service

<br/>

    $ fleetctl list-units
    UNIT				MACHINE			ACTIVE	SUB
    nginx.service			09e7fca1.../10.0.13.5	active	running
    nginx.service			16d2848f.../10.0.15.5	active	running
    nginx.service			56b7dcad.../10.0.14.5	active	running
    nginx.service			72720a60.../10.0.17.5	active	running
    nginx.service			b420d775.../10.0.11.5	active	running
    nginx.service			e5b75cfb.../10.0.12.5	active	running
    nginx.service			f8083379.../10.0.16.5	active	running
    rethinkdb-announce@6.service	09e7fca1.../10.0.13.5	active	running
    rethinkdb-announce@7.service	16d2848f.../10.0.15.5	active	running
    rethinkdb@6.service		09e7fca1.../10.0.13.5	active	running
    rethinkdb@7.service		16d2848f.../10.0.15.5	active	running
    todo-sk@3.service		b420d775.../10.0.11.5	active	running
    todo-sk@4.service		72720a60.../10.0.17.5	active	running
    todo-sk@5.service		56b7dcad.../10.0.14.5	active	running
    todo@3.service			b420d775.../10.0.11.5	active	running
    todo@4.service			72720a60.../10.0.17.5	active	running
    todo@5.service			56b7dcad.../10.0.14.5	active	running

<br/>

    $ curl 10.0.17.5:80

Ок. Контент от вебсервера через proxy

<br/>

![coreos cluster example](/img/devops/containers/coreos/example/01/pic3.png 'coreos cluster example'){: .center-image }
