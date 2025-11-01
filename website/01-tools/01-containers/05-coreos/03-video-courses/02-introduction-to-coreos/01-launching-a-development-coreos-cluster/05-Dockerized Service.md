---
layout: page
title: Introduction to CoreOS Training Video - Dockerized Service
description: Introduction to CoreOS Training Video - Dockerized Service
keywords: Introduction to CoreOS Training Video, Dockerized Service
permalink: /devops/containers/coreos/introduction-to-coreos/launching-a-development-coreos-cluster/Dockerized_Service/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Launching A Development CoreOS Cluster : Dockerized Service

### Dockerized Node.js Application

App:  
https://github.com/rosskukulinski/Introduction_To_CoreOS/tree/master/Chapter%204/Dockerized_App

    $ docker run --rm -ti -p 3000:3000 -e INSTANCE=instance1 rosskukulinski/nodeapp1


    $ docker inspect --format='' <CONTAINER_ID>

    $ curl 172.18.0.1:3000
    Hello from instance1 running on 405e83cdc97c

<br/>

    $ vi nodeapp@.service

<br/>

    [Unit]
    Description=Simple Node App %i
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill nodeapp-%i
    ExecStartPre=-/usr/bin/docker rm nodeapp-%i
    ExecStartPre=/usr/bin/docker pull rosskukulinski/nodeapp1
    ExecStart=/usr/bin/docker run \
      --name nodeapp-%i \
      --rm \
      -p 3000:3000 \
      -e INSTANCE=%i \
      rosskukulinski/nodeapp1
    ExecStop=-/usr/bin/docker rm -f nodeapp-%i

    [X-Fleet]
    Conflicts=nodeapp@*.service

<br/>

    $ fleetctl submit nodeapp@.service

<br/>

    $ fleetctl list-unit-files
    UNIT			HASH	DSTATE		STATE		TARGET
    nodeapp@.service	6f4a424	inactive	inactive	-

<br/>

    $ fleetctl start nodeapp@{1..2}.service
    Unit nodeapp@1.service inactive
    Unit nodeapp@2.service inactive
    Unit nodeapp@2.service launched on b2ca4512.../172.17.8.101
    Unit nodeapp@1.service launched on 3408f7ab.../172.17.8.103

<br/>

    $ fleetctl list-unit-files
    UNIT			HASH	DSTATE		STATE		TARGET
    nodeapp@1.service	6f4a424	launched	launched	3408f7ab.../172.17.8.103
    nodeapp@2.service	6f4a424	launched	launched	b2ca4512.../172.17.8.101

<br/>

    $ fleetctl journal -f nodeapp@1
    -- Logs begin at Mon 2016-11-21 19:43:59 UTC. --
    Nov 27 01:56:58 core-03 docker[2911]: a3ed95caeb02: Pull complete
    Nov 27 01:57:00 core-03 docker[2911]: 18c769d2766f: Pull complete
    Nov 27 01:57:00 core-03 docker[2911]: 79d76ff47734: Pull complete
    Nov 27 01:57:03 core-03 docker[2911]: 6434341d3321: Pull complete
    Nov 27 01:57:05 core-03 docker[2911]: b995f7884831: Pull complete
    Nov 27 01:57:06 core-03 docker[2911]: f67353043cb1: Pull complete
    Nov 27 01:57:07 core-03 docker[2911]: Digest: sha256:836c30b2d6c90b35642b47b496495cb82731199e13561b1c30d1b285029c0c51
    Nov 27 01:57:07 core-03 docker[2911]: Status: Downloaded newer image for rosskukulinski/nodeapp1:latest
    Nov 27 01:57:07 core-03 systemd[1]: Started Simple Node App 1.
    Nov 27 01:57:08 core-03 docker[2983]: listening on port 3000

<br/>

    $ fleetctl journal -f nodeapp@2
    -- Logs begin at Mon 2016-11-21 19:42:58 UTC. --
    Nov 27 02:13:43 core-01 docker[6373]: a3ed95caeb02: Already exists
    Nov 27 02:13:43 core-01 docker[6373]: a3ed95caeb02: Already exists
    Nov 27 02:13:43 core-01 docker[6373]: Digest: sha256:836c30b2d6c90b35642b47b496495cb82731199e13561b1c30d1b285029c0c51
    Nov 27 02:13:43 core-01 docker[6373]: Status: Image is up to date for rosskukulinski/nodeapp1:latest
    Nov 27 02:13:43 core-01 systemd[1]: Started Simple Node App 2.
    Nov 27 02:13:43 core-01 docker[6388]: /usr/bin/docker: Error response from daemon: driver failed programming external connectivity on endpoint nodeapp-2 (c9634b2d5fa32da3ab6e398679370520e9416dfec7e1f4ae18d698b908fbb98b): Bind for 0.0.0.0:3000 failed: port is already allocated.
    Nov 27 02:13:43 core-01 systemd[1]: nodeapp@2.service: Main process exited, code=exited, status=125/n/a
    Nov 27 02:13:43 core-01 docker[6416]: Error response from daemon: No such container: nodeapp-2
    Nov 27 02:13:43 core-01 systemd[1]: nodeapp@2.service: Unit entered failed state.
    Nov 27 02:13:43 core-01 systemd[1]: nodeapp@2.service: Failed with result 'exit-code'.

<br/>

    $ fleetctl list-units
    UNIT			MACHINE				ACTIVE	SUB
    nodeapp@1.service	3408f7ab.../172.17.8.103	active	running
    nodeapp@2.service	b2ca4512.../172.17.8.101	failed	failed


    core@core-01 ~ $ curl 172.17.8.101:3000
    Hello from instance1 running on 405e83cdc97c

    core@core-01 ~ $ curl 172.17.8.103:3000
    Hello from 1 running on 6bec741d893b

<br>

    $ fleetctl stop nodeapp@{1..2}.service

<br>
<br>

<br/>

    $ vi nodeapp-v2@.service

<br/>

    [Unit]
    Description=Simple Node App v2 %i
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill nodeapp-v2-%i
    ExecStartPre=-/usr/bin/docker rm nodeapp-v2-%i
    ExecStartPre=/usr/bin/docker pull rosskukulinski/nodeapp1
    ExecStart=/usr/bin/docker run \
      --name nodeapp-v2-%i \
      --rm \
      -p 3000:3000 \
      -e INSTANCE=%i \
      -h %H \
      rosskukulinski/nodeapp1
    ExecStop=-/usr/bin/docker rm -f nodeapp-v2-%i

    [X-Fleet]
    Conflicts=nodeapp-v2@*.service

<br/>

    $ fleetctl submit nodeapp-v2\@.service

<br/>

    $ fleetctl list-unit-files

<br/>

    $ fleetctl start nodeapp-v2@{1..2}.service

<br/>

    $ fleetctl list-units
    UNIT			MACHINE				ACTIVE		SUB
    nodeapp-v2@1.service	db577263.../172.17.8.102	activating	start-pre
    nodeapp-v2@2.service	3408f7ab.../172.17.8.103	failed		failed
    nodeapp@1.service	3408f7ab.../172.17.8.103	active		running
    nodeapp@2.service	b2ca4512.../172.17.8.101	failed		failed

<br/>

    $ vi nodeapp-v2\@.service

    -p 3001:3000 \

<br/>

    $ fleetctl destroy nodeapp-v2@.service nodeapp-v2@{1..2}
    $ fleetctl submit nodeapp-v2\@.service
    $ fleetctl start nodeapp-v2@{1..2}.service

<br/>

    $ fleetctl list-units
    UNIT			MACHINE				ACTIVE	SUB
    nodeapp-v2@1.service	db577263.../172.17.8.102	active	running
    nodeapp-v2@2.service	3408f7ab.../172.17.8.103	active	running

<br/>

    $ curl 172.17.8.102:3001
    Hello from 1 running on core-02

<br/>

    $ curl 172.17.8.103:3001
    Hello from 2 running on core-03
