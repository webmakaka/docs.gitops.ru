---
layout: page
title: Introduction to CoreOS Training Video - Deploying RethinkDB Database
description: Introduction to CoreOS Training Video - Deploying RethinkDB Database
keywords: Introduction to CoreOS Training Video - Deploying RethinkDB Database
permalink: /devops/containers/coreos/introduction-to-coreos/deploying-a-database-backed-web-application/deploying-rethinkdb-database/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Deploying A DatabaseBacked Web Application : Deploying RethinkDB Database

### DataBase Layer (RethinkDB) 8080 port - database admin dashboard

    $ cd ~/coreos-vagrant

<br/>

    $ vi config.rb

Прописываем:

    $forwarded_ports = {80 => 8000, 3000 => 3000, 8080 => 8080 }

<br/>

    $ vagrant reload

<br/>

    $ vagrant ssh core-01 -- -A

<br/>

core-01

<br/>

    $ vi rethinkdb-announce@.service

<br/>

{% highlight text %}

[Unit]
Description=Announce RethinkDB %i service

[Service]
EnvironmentFile=/etc/environment
ExecStart=/bin/sh -c "while true; do etcdctl set /services/rethinkdb/rethinkdb-%i \${COREOS_PUBLIC_IPV4} --ttl 60; sleep 45; done"
ExecStop=/usr/bin/etcdctl rm /services/rethinkdb/rethinkdb-%i

[X-Fleet]
X-Conflicts=rethinkdb-announce@\*.service

{% endhighlight %}

<br/>

    $ vi rethinkdb@.service

<br/>

{% highlight text %}

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
ExecStart=/bin/sh -c '/usr/bin/docker run --name rethinkdb-%i \
 -p ${COREOS_PUBLIC_IPV4}:8080:8080                        \
 -p ${COREOS_PUBLIC_IPV4}:28015:28015 \
 -p ${COREOS_PUBLIC_IPV4}:29015:29015                      \
 marley/coreos-rethinkdb:latest rethinkdb --bind all \
 --canonical-address ${COREOS_PUBLIC_IPV4} \
 $(/usr/bin/etcdctl ls /services/rethinkdb |               \
     xargs -I {} /usr/bin/etcdctl get {} |                 \
     sed s/^/"--join "/ | sed s/$/":29015"/ | \
 tr "\n" " ")'

ExecStop=/usr/bin/docker stop rethinkdb-%i

[X-Fleet]
X-ConditionMachineOf=rethinkdb-announce@%i.service

{% endhighlight %}

<br/>

    $ fleetctl submit *

<br/>

    $ fleetctl list-unit-files
    UNIT				HASH	DSTATE		STATE		TARGET
    rethinkdb-announce@.service	3f7611a	inactive	inactive	-
    rethinkdb@.service		5698af1	inactive	inactive	-

<br/>

    $ fleetctl start rethinkdb@1 rethinkdb-announce@1
    $ fleetctl start rethinkdb@2 rethinkdb-announce@2

<br/>

Несколько минут ждал, чтобы статус стал active running у всех сервисов

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    rethinkdb-announce@1.service	3408f7ab.../172.17.8.103	active	running
    rethinkdb-announce@2.service	b2ca4512.../172.17.8.101	active	running
    rethinkdb@1.service		3408f7ab.../172.17.8.103	active	running
    rethinkdb@2.service		b2ca4512.../172.17.8.101	active	running

<br/>

    $ curl 172.17.8.101:8080

<br/>

    // лог
    $ fleetctl journal -f --lines=50 rethinkdb@1
    $ fleetctl journal -f --lines=50 rethinkdb@2

    $ fleetctl journal -f --lines=50 ethinkdb-announce@1
    $ fleetctl journal -f --lines=50 ethinkdb-announce@2

<br/>

    http://172.17.8.101:8080/#servers
    http://172.17.8.103:8080/#servers

<br/>

![coreos cluster](/img/devops/containers/coreos/app5.png 'coreos cluster'){: .center-image }
