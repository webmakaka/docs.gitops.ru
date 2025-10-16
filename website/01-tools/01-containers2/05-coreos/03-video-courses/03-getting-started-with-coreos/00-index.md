---
layout: page
title: Getting Started with CoreOS [29 Nov 2016, ENG]
description: Getting Started with CoreOS [29 Nov 2016, ENG]
keywords: Getting Started with CoreOS [29 Nov 2016, ENG]
permalink: /devops/containers/coreos/getting-started-with-coreos/
---

# Getting Started with CoreOS [29 Nov 2016, ENG]

<br/>

![fleetctl](/img/devops/containers/coreos/getting-started-with-coreos/pic4.png 'fleetctl'){: .center-image }

<br/>

<br/>

    $ vi hello@.service

    [Unit]
    Description=Hello World template unit
    After=docker.service
    Requires=docker.service

    [Service]
    ExecStartPre=-/usr/bin/docker kill %p-%i
    ExecStartPre=-/usr/bin/docker rm %p-%i
    ExecStart=/usr/bin/docker run --name %p-%i busybox /bin/sh -c "while true; do echo Hello World; sleep 1; done"
    ExecStop=/usr/bin/docker stop %p-%i
    Restart=on-failure

<br/>

    $ fleetctl start hello@1
    $ fleetctl start hello@2

<br/>

    $ vi hello-discovery@.service


    [Unit]
    Description=Announce Hello Service
    BindsTo=hello@%i.service
    After=hello@%i.service

    [Service]
    ExecStart=/bin/sh -c "while true; do etcdctl set /services/hello/%i $(docker inspect -f '{{.NetworkSettings.IPAddress}}' hello-%i) --ttl 60;sleep 45;done"
    ExecStop=/usr/bin/etcdctl rm /services/hello/svc@%i

    [X-Fleet]
    MachineOf=hello@%i.service

<br/>

    $ fleetctl start hello-discovery@1
    $ fleetctl start hello-discovery@2

<br/>

    $ fleetctl list-units
    UNIT				MACHINE				ACTIVE	SUB
    hello-discovery@1.service	422b9f3c.../172.17.8.102	active	running
    hello-discovery@2.service	5e438c8c.../172.17.8.101	active	running
    hello@1.service			422b9f3c.../172.17.8.102	active	running
    hello@2.service			5e438c8c.../172.17.8.101	active	running

<br/>

    $ etcdctl ls /services/hello
    /services/hello/2
    /services/hello/1

<br/>

    $ etcdctl get /services/hello/1
    172.18.0.2

<br/>

    $ etcdctl get /services/hello/2
    172.18.0.2

<br/>

    $ fleetctl destroy hello-discovery@2

ждем 60 сек

    $ etcdctl ls /services/hello
    /services/hello/1
