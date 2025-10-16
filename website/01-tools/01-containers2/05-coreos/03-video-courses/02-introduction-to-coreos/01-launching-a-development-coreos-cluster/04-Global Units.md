---
layout: page
title: Introduction to CoreOS Training Video - Global Units
description: Introduction to CoreOS Training Video - Global Units
keywords: Introduction to CoreOS Training Video - Global Units
permalink: /devops/containers/coreos/introduction-to-coreos/launching-a-development-coreos-cluster/Global_Units/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Launching A Development CoreOS Cluster : Global Units

<br/>

### Global Units

    $ vi ~/global.service

    [Unit]
    Description=Global Hello Service
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill global-hello
    ExecStartPre=-/usr/bin/docker rm global-hello
    ExecStartPre=/usr/bin/docker pull busybox
    ExecStart=/usr/bin/docker run --name global-hello busybox /bin/sh -c "while true; do echo Hello global-hello; sleep 1; done"
    ExecStop=-/usr/bin/docker rm -f global-hello

    [X-Fleet]
    Global=true

<br/>

    $ fleetctl start global.service

<br/>

    $ fleetctl list-units
    UNIT		MACHINE				ACTIVE	SUB
    global.service	3408f7ab.../172.17.8.103	active	running
    global.service	b2ca4512.../172.17.8.101	active	running
    global.service	db577263.../172.17.8.102	active	running

<br/>

    $ journalctl -f -u global.service
    -- Logs begin at Mon 2016-11-21 19:42:58 UTC. --
    Nov 27 01:31:22 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:23 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:24 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:25 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:26 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:27 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:28 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:29 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:30 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:31 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:32 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:33 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:34 core-01 docker[3660]: Hello global-hello
    Nov 27 01:31:35 core-01 docker[3660]: Hello global-hello

<br/>

    $ fleetctl stop global.service
    $ fleetctl destroy global.service
