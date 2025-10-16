---
layout: page
title: Introduction to CoreOS Training Video - Starting Units with Fleet
description: Introduction to CoreOS Training Video - Starting Units with Fleet
keywords: Introduction to CoreOS Training Video, Starting Units with Fleet
permalink: /devops/containers/coreos/introduction-to-coreos/launching-a-development-coreos-cluster/starting-units-with-fleet/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Launching A Development CoreOS Cluster : Starting Units with Fleet

<br/>

### Statring Units with Fleet

    $ ssh-add ~/.vagrant.d/insecure_private_key

<br/>

    $ vagrant ssh core-01 -- -A

<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    3408f7ab...	172.17.8.103	-
    b2ca4512...	172.17.8.101	-
    db577263...	172.17.8.102	-

<br/>

    $ fleetctl list-unit-files
    UNIT	HASH	DSTATE	STATE	TARGET

<br/>

    $ fleetctl list-units
    UNIT	MACHINE	ACTIVE	SUB

<br/>

    # vi ~/hellofleet.service

    [Unit]
    Description=Hello Fleet Service
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill hello-fleet
    ExecStartPre=-/usr/bin/docker rm hello-fleet
    ExecStartPre=/usr/bin/docker pull busybox
    ExecStart=/usr/bin/docker run --name hello-fleet busybox /bin/sh -c "while true; do echo Hello Fleet; sleep 1; done"
    ExecStop=-/usr/bin/docker rm -f hello-fleet

<br/>

    $ fleetctl submit hellofleet.service
    Unit hellofleet.service inactive

<br/>

    $ fleetctl list-unit-files
    UNIT			HASH	DSTATE		STATE		TARGET
    hellofleet.service	9b0408f	inactive	inactive	-

<br/>

    $ fleetctl cat hellofleet.service

<br/>

    $ fleetctl load hellofleet.service
    Unit hellofleet.service loaded on 3408f7ab.../172.17.8.103

<br/>

    $ fleetctl list-units
    UNIT			MACHINE				ACTIVE		SUB
    hellofleet.service	3408f7ab.../172.17.8.103	inactive	dead

<br/>

    $ fleetctl start hellofleet
    Unit hellofleet.service launched on 3408f7ab.../172.17.8.103

<br/>

    $ fleetctl list-units
    UNIT			MACHINE				ACTIVE	SUB
    hellofleet.service	3408f7ab.../172.17.8.103	active	running

<br/>

    $ fleetctl status hellofleet
    The authenticity of host '172.17.8.103' can't be established.
    ECDSA key fingerprint is c2:8e:3f:50:c5:20:db:7a:6d:91:4b:73:fc:a8:f8:41.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '172.17.8.103' (ECDSA) to the list of known hosts.
    ● hellofleet.service - Hello Fleet Service
       Loaded: loaded (/run/fleet/units/hellofleet.service; linked-runtime; vendor p
       Active: active (running) since Sun 2016-11-27 01:09:16 UTC; 1min 2s ago
      Process: 1392 ExecStartPre=/usr/bin/docker pull busybox (code=exited, status=0
      Process: 1387 ExecStartPre=/usr/bin/docker rm hello-fleet (code=exited, status
      Process: 1292 ExecStartPre=/usr/bin/docker kill hello-fleet (code=exited, stat
     Main PID: 1405 (docker)
        Tasks: 7
       Memory: 24.4M
          CPU: 127ms
       CGroup: /system.slice/hellofleet.service
               └─1405 /usr/bin/docker run --name hello-fleet busybox /bin/sh -c whil

    Nov 27 01:10:09 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:10 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:11 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:12 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:13 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:14 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:15 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:16 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:17 core-03 docker[1405]: Hello Fleet
    Nov 27 01:10:18 core-03 docker[1405]: Hello Fleet

<br/>

    $ fleetctl journal hellofleet
    -- Logs begin at Mon 2016-11-21 19:43:59 UTC, end at Sun 2016-11-27 01:11:39 UTC. --
    Nov 27 01:11:30 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:31 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:32 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:33 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:34 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:35 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:36 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:37 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:38 core-03 docker[1405]: Hello Fleet
    Nov 27 01:11:39 core-03 docker[1405]: Hello Fleet

<br/>

    $ fleetctl journal -f hellofleet

<br/>

    $ fleetctl stop hellofleet.service

<br/>

    $ fleetctl list-units
    UNIT			MACHINE				ACTIVE	SUB
    hellofleet.service	3408f7ab.../172.17.8.103	failed	failed

<br/>

    $ fleetctl unload hellofleet.service

<br/>

    $ fleetctl destroy hellofleet.service
