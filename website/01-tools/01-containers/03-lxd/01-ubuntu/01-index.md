---
layout: page
title: Ubuntu Linux Containers (lxc) (Наверное устарело по большей части)
description: Ubuntu Linux Containers (lxc) (Наверное устарело по большей части)
keywords: DevOps, Ubuntu Linux Containers (lxc) (Наверное устарело по большей части)
permalink: /devops/containers/lxd/ubuntu/archive/
---

# Ubuntu: Linux Containers (lxc) (Наверное устарело по большей части)

<pre>

$ sudo su -
root@webserv:~# apt-get update

<strong>Подготовка родительской (хост) системы</strong>

root@webserv:~# apt-get install -y bridge-utils


root@webserv:~# vi /etc/network/interfaces

auto lo
iface lo inet loopback


auto br0
iface br0 inet static
        address 192.168.1.10
        netmask 255.255.255.0
        gateway 192.168.1.1
        bridge_ports eth0
        bridge_stp off
        bridge_maxwait 0
        post-up /sbin/brctl setfd br0 0


root@webserv:~# /etc/init.d/networking restart


<strong>Установка и настройка lxc</strong>


root@webserv:~# apt-get install -y lxc

root@webserv:~# vi /etc/default/lxc

USE_LXC_BRIDGE="true"
меняем на
USE_LXC_BRIDGE="false"


<strong>Подготовка дочерней (гостевой) системы</strong>

Создание ветки дочерней системы

root@webserv:~# lxc-create -t ubuntu -n mail


root@webserv:~#  chroot /var/lib/lxc/mail/rootfs /bin/bash

root@webserv:/# PS1='mail:\w# '

mail:/# apt-get update


mail:/# apt-get install -y language-pack-en


mail:/# update-locale LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" LC_CTYPE="C"

mail:/# apt-get purge -y resolvconf isc-dhcp-client




<strong>Настойка сетевых параметров дочерней системы</strong>

mail:/# vi /etc/hostname
mail.corpX.un

mail:/# vi /etc/hosts
192.168.1.20    mail.corpX.un mail


mail:/# vi /etc/resolv.conf
nameserver 192.168.1.1

mail:/# vi /etc/rc.local
route add default gw 192.168.1.1

exit 0



<strong>Управление учетными записями в дочерней системе</strong>


mail:/# useradd marley
mail:/# passwd marley

mail:/# passwd root

mail:/# exit


<strong>Настройка lxc для запуска дочерней системы в контейнере</strong>


root@webserv:~# vi /var/lib/lxc/mail/config

меняю
lxc.network.link=lxcbr0
на
lxc.network.link=br0

добавляю
lxc.network.ipv4=192.168.1.20/24


root@webserv:~# lxc-ls
mail



<strong>Запуск/мониторинг/остановка контейнера</strong>



root@server:~# lxc-start -n mail -d

root@server:~# lxc-info --name mail
'mail' is RUNNING

root@webserv:~# lxc-ps --name mail
CONTAINER    PID TTY          TIME CMD
mail       18017 ?        00:00:00 init
mail       18123 ?        00:00:00 upstart-udev-br
mail       18154 ?        00:00:00 sshd
mail       18167 ?        00:00:00 ntpdate
mail       18172 ?        00:00:00 upstart-socket-
mail       18174 ?        00:00:00 udevd
mail       18193 ?        00:00:00 lockfile-touch
mail       18197 ?        00:00:00 ntpdate
mail       18205 ?        00:00:00 rsyslogd
mail       18219 pts/4    00:00:00 getty
mail       18225 pts/2    00:00:00 getty
mail       18226 pts/3    00:00:00 getty
mail       18228 ?        00:00:00 cron
mail       18235 ?        00:00:00 ondemand
mail       18238 ?        00:00:00 sleep
mail       18247 pts/5    00:00:00 getty
mail       18252 pts/1    00:00:00 getty


root@server:~# ping 192.168.1.20
root@server:~# ssh marley@192.168.1.20

\$ hostname
mail.corpX.un

CTRL + D

root@server:~# lxc-stop --name mail

<!--
root@server:~# vi /etc/default/lxc

...
RUN=yes
CONF_DIR=/var/lib/lxc/
CONTAINERS="mail"
...

-->

=======================

<strong>Почитать:</strong>

http://wiki.val.bmstu.ru/doku.php?id=%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5_%D0%BE%D1%82%D0%BA%D0%B0%D0%B7%D0%BE%D1%83%D1%81%D1%82%D0%BE%D0%B9%D1%87%D0%B8%D0%B2%D1%8B%D1%85_unix_%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D0%B9

https://help.ubuntu.com/12.04/serverguide/lxc.html

</pre>
