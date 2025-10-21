---
layout: page
title: Настройка сетевых адаптеров в CoreOS
description: Настройка сетевых адаптеров в CoreOS
keywords: Настройка сетевых адаптеров в CoreOS
permalink: /devops/containers/coreos/network/
---

# Настройка сети в CoreOS

    $ sudo su -

    # vi /etc/systemd/network/static.network

<br/>

    [Match]
    Name=enp0s8

    [Network]
    Address=192.168.1.11/24
    Gateway=192.168.1.1
    DNS=192.168.1.1

<br/>

    # systemctl restart systemd-networkd

Не помогло, пришлось рестартовать.

<br/><br/>

    $ ssh core@192.168.1.11

<br/>

    core@my_vm01 ~ $ ping ya.ru
    PING ya.ru (93.158.134.3) 56(84) bytes of data.
    64 bytes from ya.ru (93.158.134.3): icmp_seq=1 ttl=55 time=4.37 ms
    64 bytes from ya.ru (93.158.134.3): icmp_seq=2 ttl=55 time=2.39 ms
