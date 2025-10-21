---
layout: page
title: Introduction to CoreOS Training Video - Deploying Web Application
description: Introduction to CoreOS Training Video - Deploying Web Application
keywords: Introduction to CoreOS Training Video - Deploying Web Application
permalink: /devops/containers/coreos/introduction-to-coreos/deploying-a-database-backed-web-application/deploying-web-application/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Deploying A DatabaseBacked Web Application : Deploying Web Application

<br/>

### Deploying Web Application

<br/>

core-01

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    3408f7ab...	172.17.8.103	-
    b2ca4512...	172.17.8.101	-
    db577263...	172.17.8.102	-

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    rethinkdb-announce@1.service	3408f7ab.../172.17.8.103	active	running
    rethinkdb-announce@2.service	b2ca4512.../172.17.8.101	active	running
    rethinkdb@1.service		3408f7ab.../172.17.8.103	active	running
    rethinkdb@2.service		b2ca4512.../172.17.8.101	active	running

<br/>

    $ etcdctl get /services/rethinkdb/rethinkdb-1
    172.17.8.103

    $ etcdctl get /services/rethinkdb/rethinkdb-2
    172.17.8.101

<br/>

Я заменил оригинальные image, своими. Они отличаются пока только IP адресом.
С оригинальным у меня не заработало.

<br/>

**\$ vi todo@.service**

{% highlight text %}

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
ExecStartPre=/usr/bin/docker pull marley/coreos-todo-angular-express
ExecStart=/usr/bin/docker run --name %p-%i \
 -h %H \
 -p \${COREOS_PUBLIC_IPV4}:3000:3000 \
 -e INSTANCE=%p-%i \
 marley/coreos-todo-angular-express
ExecStop=-/usr/bin/docker kill %p-%i
ExecStop=-/usr/bin/docker rm %p-%i

[X-Fleet]
Conflicts=todo@\*.service

{% endhighlight %}

<br/>

**\$ vi todo-sk@.service**

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
 port=$(docker inspect --format=\'{{(index (index .NetworkSettings.Ports "3000/tcp") 0).HostPort}}\' todo-%i); \
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

    $ fleetctl submit todo*

<br/>

    $ fleetctl start todo@{1..3} todo-sk@{1..3}

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    rethinkdb-announce@1.service	3408f7ab.../172.17.8.103	active	running
    rethinkdb-announce@2.service	b2ca4512.../172.17.8.101	active	running
    rethinkdb@1.service		3408f7ab.../172.17.8.103	active	running
    rethinkdb@2.service		b2ca4512.../172.17.8.101	active	running
    todo-sk@1.service		db577263.../172.17.8.102	active	running
    todo-sk@2.service		b2ca4512.../172.17.8.101	active	running
    todo-sk@3.service		3408f7ab.../172.17.8.103	active	running
    todo@1.service			db577263.../172.17.8.102	active	running
    todo@2.service			b2ca4512.../172.17.8.101	active	running
    todo@3.service			3408f7ab.../172.17.8.103	active	running

<br/>

    $ fleetctl journal -f --lines=50 todo@1
    $ fleetctl journal -f --lines=50 todo-sk@1

<br/>

    $ etcdctl ls --recursive
    /test
    /test/hello
    /services
    /services/rethinkdb
    /services/rethinkdb/rethinkdb-1
    /services/rethinkdb/rethinkdb-2
    /services/todo
    /services/todo/todo-2
    /services/todo/todo-1
    /services/todo/todo-3
    /coreos.com
    /coreos.com/network
    /coreos.com/network/config
    /coreos.com/network/subnets
    /coreos.com/network/subnets/10.1.99.0-24
    /coreos.com/network/subnets/10.1.34.0-24
    /coreos.com/network/subnets/10.1.29.0-24
    /coreos.com/updateengine
    /coreos.com/updateengine/rebootlock
    /coreos.com/updateengine/rebootlock/semaphore
    /foo
    /foo/bar
    /foo/bar2

<br/>

    $ etcdctl get /services/todo/todo-3
    172.17.8.101:3000

<br/>

    http://172.17.8.101:3000/
    http://172.17.8.102:3000/
    http://172.17.8.103:3000/

<br/>

![coreos cluster](/img/devops/containers/coreos/app6.png 'coreos cluster'){: .center-image }

<br/>

Если нужно все остановить и почистить:

    $ fleetctl stop todo@{1..3} todo-sk@{1..3}
    $ fleetctl unload todo@{1..3} todo-sk@{1..3}

    $ fleetctl destroy todo@.service
    $ fleetctl destroy todo@1.service
    $ fleetctl destroy todo@2.service
    $ fleetctl destroy todo@3.service

    $ fleetctl destroy todo-sk@.service
    $ fleetctl destroy todo-sk@1.service
    $ fleetctl destroy todo-sk@2.service
    $ fleetctl destroy todo-sk@3.service
