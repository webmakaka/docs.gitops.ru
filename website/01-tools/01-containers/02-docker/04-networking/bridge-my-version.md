---
layout: page
title: Задание параметров сетевых интерфейсов docker в Ubuntu (IP, gateway, etc.)
description: Задание параметров сетевых интерфейсов docker в Ubuntu (IP, gateway, etc.)
keywords: devops, docker, Задание параметров сетевых интерфейсов docker в Ubuntu (IP, gateway, etc.)
permalink: /devops/containers/docker/networking/ubuntu-bridge/bridge-my-version/
---

# Задание параметров сетевых интерфейсов docker в Ubuntu (IP, gateway, etc.)

Делалось для Docker версии 1.X

Сейчас, они что-то там пилят, но пока все сырое.

https://github.com/docker/libnetwork/blob/master/docs/overlay.md

https://github.com/docker/libnetwork

<br/>

### Как делал я (когда только приступил изучать и мне очень не хватало отсутствие у контейнеров ip адресации)

Может есть вариант и попроще.

    $ sudo service docker.io status
    docker.io start/running, process 6536

<br/>

    $ ifconfig
    docker0   Link encap:Ethernet  HWaddr aa:f0:35:9b:72:10
              inet addr:172.17.42.1  Bcast:0.0.0.0  Mask:255.255.0.0
              inet6 addr: fe80::507e:2fff:fea1:6ae0/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:18 errors:0 dropped:0 overruns:0 frame:0
              TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:1224 (1.2 KB)  TX bytes:648 (648.0 B)

    eth0      Link encap:Ethernet  HWaddr bc:ae:c5:30:13:a5
              inet addr:192.168.1.5  Bcast:192.168.1.255  Mask:255.255.255.0
              inet6 addr: fe80::beae:c5ff:fe30:13a5/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:60789443 errors:0 dropped:73 overruns:0 frame:0
              TX packets:72579419 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:47728813127 (47.7 GB)  TX bytes:81564408216 (81.5 GB)

    lo        Link encap:Local Loopback
              inet addr:127.0.0.1  Mask:255.0.0.0
              inet6 addr: ::1/128 Scope:Host
              UP LOOPBACK RUNNING  MTU:65536  Metric:1
              RX packets:258380 errors:0 dropped:0 overruns:0 frame:0
              TX packets:258380 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:311261549 (311.2 MB)  TX bytes:311261549 (311.2 MB)

    veth5f79  Link encap:Ethernet  HWaddr aa:f0:35:9b:72:10
              inet6 addr: fe80::a8f0:35ff:fe9b:7210/64 Scope:Link
              UP BROADCAST RUNNING  MTU:1500  Metric:1
              RX packets:9 errors:0 dropped:0 overruns:0 frame:0
              TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:738 (738.0 B)  TX bytes:648 (648.0 B)

<br/>

### Создание моста

    $ sudo apt-get install bridge-utils

<br/>

Без lxc возникала ошибка при вызове контейнера с параметрами:

> Error: Cannot start container 15251ef28c49d0cffeedcec5f90677c58cd2a4fba385f9335414eeb56deab440: lxc.network.ipv4 = 192.168.1.25/24 is not supported by the native driver

Устанавливаем lxc

    $ sudo apt-get install lxc

<br/>

// Удаляю Network Manager и resolvconf

    $ sudo apt-get remove network-manager
    $ sudo apt-get remove resolvconf

<br/>

    $ sudo vi /etc/network/interfaces

<br/>

    auto lo
    iface lo inet loopback


    auto br0
    iface br0 inet static
            address 192.168.1.5
            netmask 255.255.255.0
            gateway 192.168.1.1
            bridge_ports eth0
            bridge_stp off
            bridge_maxwait 0
            post-up /sbin/brctl setfd br0 0

<br/>

    $ sudo vi /etc/resolv.conf
    nameserver 192.168.1.1

<br/>

    $ sudo reboot

<br/>

### Настройка docker для работы с мостом

// Вырубаю докер с его виртуальным адаптером

    $ sudo service docker.io stop
    $ sudo ip link set dev docker0 down
    $ sudo brctl delbr docker0

<br/>

    $ sudo vi /etc/default/docker.io
    DOCKER_OPTS="-b=br0 -d -e lxc"

<br/>

    -b=br0 - использовать созданный мост
    -e lxc - использовать расширения lxc, чтобы работали ключи --lxc-conf.
    -d - стартовать в режиме демона.

<br/>

    $ sudo service docker.io restart

<br/>

    $ brctl show
    bridge name	bridge id		STP enabled	interfaces
    br0		8000.bcaec53013a5	no		eth0
    							veth9fe6

<br/>

### Запуск контейнера docker с нужными настройками сети

    $ sudo docker  run -i -t \
    --lxc-conf="lxc.network.ipv4 = 192.168.1.11/24" \
    centos:centos6 /bin/bash

Можно более подробно задать параметры

    $ sudo docker run \
    -n=false \
    -lxc-conf="lxc.network.ipv4 = 172.16.42.20/24" \
    -lxc-conf="lxc.network.ipv4.gateway = 172.16.42.1" \
    -lxc-conf="lxc.network.link = docker0" \
    -lxc-conf="lxc.network.name = eth0" \
    -lxc-conf="lxc.network.flags = up" \
    -i -t centos:centos6 /bin/bash

Сейчас работаю в основном с 1 контейнером docker.
Настройка сети при этом не нужна.

Последняя версия, с которой пробовал работать с параметрами lxc-conf была версия docker 1.3.

При этом контейнер помимо заданного ip адреса, назначал свой. Возможно, что docker брал первый попавшийся свободный ip из подсети. По идее, опция -n=false должна решать эту проблему. Но сейчас уже не помню. Вроде этого было недостаточно. Возможно, что в новых версиях исправили.

Почитать:
http://askubuntu.com/questions/452611/how-to-use-docker-io-containers-in-ubuntu-14-04-with-ipv6
