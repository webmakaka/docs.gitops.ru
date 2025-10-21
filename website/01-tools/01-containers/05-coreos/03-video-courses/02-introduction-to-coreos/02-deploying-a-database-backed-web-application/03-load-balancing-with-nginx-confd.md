---
layout: page
title: Introduction to CoreOS Training Video - Load balancing with NGINX
description: Introduction to CoreOS Training Video - Load balancing with NGINX
keywords: Introduction to CoreOS Training Video - Load balancing with NGINX
permalink: /devops/containers/coreos/introduction-to-coreos/deploying-a-database-backed-web-application/load-balancing-with-nginx-confd/
---

# Load balancing with NGINX

<br/>

core-01

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    rethinkdb-announce@1.service	3408f7ab.../172.17.8.103	active	running
    rethinkdb-announce@2.service	b2ca4512.../172.17.8.101	active	running
    rethinkdb@1.service		3408f7ab.../172.17.8.103	active	running
    rethinkdb@2.service		b2ca4512.../172.17.8.101	active	running
    todo-sk@1.service		3408f7ab.../172.17.8.103	active	running
    todo-sk@2.service		db577263.../172.17.8.102	active	running
    todo-sk@3.service		b2ca4512.../172.17.8.101	active	running
    todo@1.service			3408f7ab.../172.17.8.103	active	running
    todo@2.service			db577263.../172.17.8.102	active	running
    todo@3.service			b2ca4512.../172.17.8.101	active	running

<br/>

Я заменил оригинальные image, своими. Они отличаются пока только IP адресом.
С оригинальным у меня не заработало.

<br/>

**\$ vi nginx.service**

<br/>

{% highlight text %}

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
ExecStartPre=-/usr/bin/docker pull marley/coreos-nginx-proxy
ExecStart=/usr/bin/docker run --name %p-%i \
 -h %H \
 -p \${COREOS_PUBLIC_IP}:80:80 \
 marley/coreos-nginx-proxy
ExecStop=-/usr/bin/docker kill %p-%i
ExecStop=-/usr/bin/docker rm %p-%i

[X-Fleet]
Global=true

{% endhighlight %}

<br/>

    $ fleetctl submit nginx.service
    $ fleetctl start nginx.service

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    nginx.service			3408f7ab.../172.17.8.103	active	running
    nginx.service			b2ca4512.../172.17.8.101	active	running
    nginx.service			db577263.../172.17.8.102	active	running
    rethinkdb-announce@1.service	3408f7ab.../172.17.8.103	active	running
    rethinkdb-announce@2.service	b2ca4512.../172.17.8.101	active	running
    rethinkdb@1.service		3408f7ab.../172.17.8.103	active	running
    rethinkdb@2.service		b2ca4512.../172.17.8.101	active	running
    todo-sk@1.service		3408f7ab.../172.17.8.103	active	running
    todo-sk@2.service		db577263.../172.17.8.102	active	running
    todo-sk@3.service		b2ca4512.../172.17.8.101	active	running
    todo@1.service			3408f7ab.../172.17.8.103	active	running
    todo@2.service			db577263.../172.17.8.102	active	running
    todo@3.service			b2ca4512.../172.17.8.101	active	running

<br/>

// логи

    $ journalctl -f --lines -u nginx

<br/>

    http://172.17.8.101/
    http://172.17.8.102/
    http://172.17.8.103/

Тоже самое, только на 80 порту а не на 3000

![coreos cluster](/img/devops/containers/coreos/app7.png 'coreos cluster'){: .center-image }

Если нужно остановить и выгрузить все, что касается сервиса:

    $ fleetctl stop nginx.service
    $ fleetctl unload nginx.service
    $ fleetctl destroy nginx.service
