---
layout: page
title: Настройка моста для работы с Docker в Ubuntu
description: Настройка моста для работы с Docker в Ubuntu
keywords: devops, docker, Настройка моста для работы с Docker в Ubuntu
permalink: /devops/containers/docker/networking/ubuntu-bridge/
---

# Настройка моста для работы с Docker в Ubuntu

Делалось для Docker версии 1.X

<br/>

    sudo apt-get install bridge-utils

<br/>

    sudo brctl show docke0

<br/>

    sudo service docker stop
    sudo ip link set dev docker0 down

<br/>

    sudo brctl delbr docke0
    sudo brctl addbr bridge0
    sudo ip addr add 192.168.0.1/24 dev brigde0
    sudo ip link set dev bridge0 up

<br/>

    vi /etc/default

<br/>

    DOCKER_OPTS=" -b=bridge0"

<br/>

    sudo service docker start
