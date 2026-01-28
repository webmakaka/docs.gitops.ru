---
layout: page
title: Introduction to CoreOS Training Video - Launching A Development CoreOS Cluster systemd
description: Introduction to CoreOS Training Video - Launching A Development CoreOS Cluster systemd
keywords: coreos, systemd
permalink: /devops/containers/coreos/introduction-to-coreos/launching-a-development-coreos-cluster/systemd/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Launching A Development CoreOS Cluster : systemd

    core@core-01 ~ $ sudo su -
    core-01 ~ # cd /etc/systemd/system

### Пример 1:

    core-01 system # vi helloworld.service

<br/>

    [Unit]
    Description=Hello World Service
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill hello-world
    ExecStartPre=-/usr/bin/docker rm hello-world
    ExecStartPre=/usr/bin/docker pull busybox
    ExecStart=/usr/bin/docker run --name hello-world busybox /bin/sh -c "while true; do echo Hello World; sleep 1; done"
    ExecStop=-/usr/bin/docker rm -f hello-world


    [Install]
    WantedBy=multi-user.target

<br/>

    # systemctl enable helloworld.service
    # systemctl start helloworld.service
    # systemctl status helloworld.service

    # journalctl -f -u helloworld.service

    # systemctl stop helloworld.service

<br/>

### Пример 2:

    # vi helloworld2@.service

<br/>

    [Unit]
    Description=%n Service
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill %p-%i
    ExecStartPre=-/usr/bin/docker rm %p-%i
    ExecStartPre=/usr/bin/docker pull busybox
    ExecStart=/usr/bin/docker run --name %p-%i busybox /bin/sh -c "while true; do echo Hello from %p-%i running on %H; sleep 1; done"
    ExecStop=-/usr/bin/docker rm -f %p-%i

    [Install]
    WantedBy=multi-user.target

<br/>

    # systemctl start helloworld2@1.service
    # journalctl -f -u helloworld2@1.service

    # systemctl start helloworld2@{2..4}.service

    # docker ps

    # systemctl stop helloworld2@{1..4}.service
