---
layout: page
title: Coreos Small cluster > Пример запуска coreos кластера с контейнерами docker, приложением, базой данных и прокси сервером
permalink: /devops/containers/coreos/example/01/
---


# Coreos Small cluster > Пример запуска coreos кластера с контейнерами docker, приложением, базой данных и прокси сервером

По материалам из видео курса:  

**[O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG]**

Советы по улучшению, принимаются.


<br/>

PS. Исходники с Dockerfile, можно взять здесь:

https://github.com/sysadm-ru/coreos-docker-examples/tree/master/01


Они могу понадобиться, если захочется собрать собственные контейнеры или просто посмотреть примеры.


<br/>

### Базы данных RethinkDB

    $ vagrant ssh core-01


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
    COREOS_PUBLIC_IPV4=172.17.8.101
    COREOS_PRIVATE_IPV4=172.17.8.101

<br/>

    $ echo $(/usr/bin/etcdctl ls /services/rethinkdb |               \
              xargs -I {} /usr/bin/etcdctl get {} |                 \
              sed s/^/"--join "/ | sed s/$/":29015"/ |              \
              tr "\n" " ")
    --join 172.17.8.107:29015 --join 172.17.8.101:29015



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
    UNIT				MACHINE				ACTIVE	SUB
    rethinkdb-announce@6.service	010edf2c.../172.17.8.107	active	running
    rethinkdb-announce@7.service	0f1619f3.../172.17.8.101	active	running
    rethinkdb@6.service		010edf2c.../172.17.8.107	active	running
    rethinkdb@7.service		0f1619f3.../172.17.8.101	active	running


<br/>

    $ curl 172.17.8.107:8080

Все ок. получил контент от сервера баз данных.


<br/>

![coreos cluster example](/img/devops/containers/coreos/example/01/pic1.png "coreos cluster example"){: .center-image }


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
    172.17.8.107

    $ etcdctl get /services/rethinkdb/rethinkdb-7
    172.17.8.101


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
          -e COREOS_PRIVATE_IPV4=${COREOS_PRIVATE_IPV4} \
          marley/coreos-nodejs-web-app
    ExecStop=-/usr/bin/docker kill %p-%i
    ExecStop=-/usr/bin/docker rm %p-%i

    [X-Fleet]
    Conflicts=todo@*.service


<br/>


-e COREOS_PRIVATE_IPV4=${COREOS_PRIVATE_IPV4} - экспортирую переменную, чтобы она была доступна в контейнере.

<br/>

    $ vi todo-sk@.service

<br/>


**Какая-то проблема с движком сайта. Он не хочет печатать параметры --format. Предлагаю смотреть исходник на github**

https://github.com/sysadm-ru/coreos-docker-examples/blob/master/01/coreos-nodejs-web-app/todo-sk%40.service


{% highlight text %}

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

{% endhighlight %}

<br/>


// Что выполняет следующая команда?

{% highlight text %}

$ docker inspect --format="{{(index (index .NetworkSettings.Ports \"3000/tcp\") 0).HostPort}}" todo-3

{% endhighlight %}



// Сначала нужно переключиться на сервер, где стартован сервис

    $ fleetctl ssh todo-sk@3.service

// Следующая команда должна будет возвращать порт на котором работает вебсервер.

{% highlight text %}

$ docker inspect --format="{{(index (index .NetworkSettings.Ports \"3000/tcp\") 0).HostPort}}" todo-3

{% endhighlight %}

3000


<br/>

    $ fleetctl submit todo*


<br/>

    $ fleetctl list-unit-files
    UNIT				HASH	DSTATE		STATE		TARGET
    rethinkdb-announce@.service	3f7611a	inactive	inactive	-
    rethinkdb-announce@6.service	3f7611a	launched	launched	010edf2c.../172.17.8.107
    rethinkdb-announce@7.service	3f7611a	launched	launched	0f1619f3.../172.17.8.101
    rethinkdb@.service		96c6e09	inactive	inactive	-
    rethinkdb@6.service		96c6e09	launched	launched	010edf2c.../172.17.8.107
    rethinkdb@7.service		96c6e09	launched	launched	0f1619f3.../172.17.8.101
    todo-sk@.service		e8b8fa1	inactive	inactive	-
    todo@.service			094d679	inactive	inactive	-



<br/>

    $ fleetctl start todo@{3..5} todo-sk@{3..5}

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    rethinkdb-announce@6.service	010edf2c.../172.17.8.107	active	running
    rethinkdb-announce@7.service	0f1619f3.../172.17.8.101	active	running
    rethinkdb@6.service		010edf2c.../172.17.8.107	active	running
    rethinkdb@7.service		0f1619f3.../172.17.8.101	active	running
    todo-sk@3.service		43425159.../172.17.8.103	active	running
    todo-sk@4.service		2320be18.../172.17.8.106	active	running
    todo-sk@5.service		6c66d6fb.../172.17.8.102	active	running
    todo@3.service			43425159.../172.17.8.103	active	running
    todo@4.service			2320be18.../172.17.8.106	active	running
    todo@5.service			6c66d6fb.../172.17.8.102	active	running



<br/>

    $ curl 172.17.8.103:3000

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

    $ etcdctl get /services/todo/todo-3          
    172.17.8.103:3000

    $ etcdctl get /services/todo/todo-4          
    172.17.8.106:3000

    $ etcdctl get /services/todo/todo-5          
    172.17.8.102:3000


<br/>


![coreos cluster example](/img/devops/containers/coreos/example/01/pic2.png "coreos cluster example"){: .center-image }


<br/>


**На самом деле, с первого раза ничего не запустилось**


    // Переключиться на хост, где стартован сервис, можно следующей командой

    $ fleetctl ssh todo-sk@3.service


    // логи

    $ fleetctl journal -f --lines=100 todo@3
    $ fleetctl journal -f --lines=100 todo-sk@3


<br/>

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
          -e COREOS_PRIVATE_IPV4=${COREOS_PRIVATE_IPV4} \
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
    nginx.service			ab2c0e2	inactive	-		global
    rethinkdb-announce@.service	3f7611a	inactive	inactive	-
    rethinkdb-announce@6.service	3f7611a	launched	launched	010edf2c.../172.17.8.107
    rethinkdb-announce@7.service	3f7611a	launched	launched	0f1619f3.../172.17.8.101
    rethinkdb@.service		96c6e09	inactive	inactive	-
    rethinkdb@6.service		96c6e09	launched	launched	010edf2c.../172.17.8.107
    rethinkdb@7.service		96c6e09	launched	launched	0f1619f3.../172.17.8.101
    todo-sk@.service		e8b8fa1	inactive	inactive	-
    todo-sk@3.service		e8b8fa1	launched	launched	43425159.../172.17.8.103
    todo-sk@4.service		e8b8fa1	launched	launched	2320be18.../172.17.8.106
    todo-sk@5.service		e8b8fa1	launched	launched	6c66d6fb.../172.17.8.102
    todo@.service			094d679	inactive	inactive	-
    todo@3.service			094d679	launched	launched	43425159.../172.17.8.103
    todo@4.service			094d679	launched	launched	2320be18.../172.17.8.106
    todo@5.service			094d679	launched	launched	6c66d6fb.../172.17.8.102

<br/>

    $ fleetctl start nginx.service

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    nginx.service			010edf2c.../172.17.8.107	active	running
    nginx.service			0f1619f3.../172.17.8.101	active	running
    nginx.service			2320be18.../172.17.8.106	active	running
    nginx.service			43425159.../172.17.8.103	active	running
    nginx.service			6c66d6fb.../172.17.8.102	active	running
    nginx.service			98b5dead.../172.17.8.105	active	running
    nginx.service			e45abe65.../172.17.8.104	active	running
    rethinkdb-announce@6.service	010edf2c.../172.17.8.107	active	running
    rethinkdb-announce@7.service	0f1619f3.../172.17.8.101	active	running
    rethinkdb@6.service		010edf2c.../172.17.8.107	active	running
    rethinkdb@7.service		0f1619f3.../172.17.8.101	active	running
    todo-sk@3.service		43425159.../172.17.8.103	active	running
    todo-sk@4.service		2320be18.../172.17.8.106	active	running
    todo-sk@5.service		6c66d6fb.../172.17.8.102	active	running
    todo@3.service			43425159.../172.17.8.103	active	running
    todo@4.service			2320be18.../172.17.8.106	active	running
    todo@5.service			6c66d6fb.../172.17.8.102	active	running

<br/>

    $ curl 172.17.8.101:80

Ок. Контент от вебсервера через proxy


<br/>


![coreos cluster example](/img/devops/containers/coreos/example/01/pic3.png "coreos cluster example"){: .center-image }
