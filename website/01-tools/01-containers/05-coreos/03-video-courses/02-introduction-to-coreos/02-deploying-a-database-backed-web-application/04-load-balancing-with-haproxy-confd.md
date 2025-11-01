---
layout: page
title: Introduction to CoreOS Training Video - Load balancing with HAPROXY & CONFD
description: Introduction to CoreOS Training Video - Load balancing with HAPROXY & CONFD
keywords: Introduction to CoreOS Training Video - Load balancing with HAPROXY & CONFD
permalink: /devops/containers/coreos/introduction-to-coreos/deploying-a-database-backed-web-application/load-balancing-with-haproxy-confd/
---

# Load balancing with HAPROXY & CONFD

<br/>

Имеем:

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

Я заменил оригинальные image, своими. Они отличаются только IP адресом.
С оригинальным у меня не заработало.

<br/>

**\$ vi haproxy.service**

<br/>

{% highlight text %}

[Unit]
Description=haproxy Proxy

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
ExecStartPre=-/usr/bin/docker pull marley/coreos-haproxy
ExecStart=/usr/bin/docker run --name %p-%i \
 -h %H \
 -p \${COREOS_PUBLIC_IP}:80:80 \
 marley/coreos-haproxy
ExecStop=-/usr/bin/docker kill %p-%i
ExecStop=-/usr/bin/docker rm %p-%i

[X-Fleet]
Global=true

{% endhighlight %}

<br/>

    $ fleetctl submit haproxy.service
    $ fleetctl start haproxy.service

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    haproxy.service			3408f7ab.../172.17.8.103	active	running
    haproxy.service			b2ca4512.../172.17.8.101	active	running
    haproxy.service			db577263.../172.17.8.102	active	running
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

    $ journalctl -f --lines=50 -u haproxy

<br/>

    http://172.17.8.101/
    http://172.17.8.102/
    http://172.17.8.103/

Все работает!

Если нужно остановить и выгрузить все, что касается сервиса:

    $ fleetctl stop haproxy.service
    $ fleetctl unload haproxy.service
    $ fleetctl destroy haproxy.service
