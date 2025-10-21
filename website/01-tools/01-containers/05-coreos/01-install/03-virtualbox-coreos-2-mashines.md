---
layout: page
title: Инсталляция CoreOS на 2х виртуальных машинах virtualBox
permalink: /devops/containers/coreos/install/virtualbox-coreos-2-machines/
---

# Подготовка виртуального жесткого диска virtualbox с coreos

Создаю каталог, где будет все это добро храниться.

    $ mkdir -p /mnt/dsk0/machines/coreos/

    $ cd /mnt/dsk0/machines/coreos/

Следующий скрипт поможет нам скачать последнюю стабильную версию coreos

    $ wget $ https://raw.github.com/coreos/scripts/master/contrib/create-coreos-vdi

    $ chmod +x create-coreos-vdi

    $ ./create-coreos-vdi -V stable -d .

Лучше сразу расширить место на диске, чтобы можно было побольше всяких имиджей накачать. По умолчанию диск на 698M.

    $ VBoxManage modifyhd coreos_production_835.11.0.vdi --resize 20480

    $ mv coreos_production_835.11.0.vdi coreos1.vdi

    $ VBoxManage clonehd coreos1.vdi coreos2.vdi

<br/>

### Создаем Config-Drive

Для начала, нужно сгенерировать rsa ключ на хосте (если он не был создан ранее).

    $ ssh-keygen -t rsa

На все вопросы [Enter]

    $ wget https://raw.github.com/coreos/scripts/master/contrib/create-basic-configdrive

    $ mv create-basic-configdrive coreos1-config-drive

https://discovery.etcd.io/new?size=3

Генерирую ключ

Получилось
https://discovery.etcd.io/126282ce7e06b79eae0d6e1d78c9c73c

<br/>

    $ vi coreos1-config-drive

Устанавливаю значение для параметра DEFAULT_ETCD_PEER_URLS

    DEFAULT_ETCD_PEER_URLS="http://192.168.1.11:2380"

<br/>

После:

    - name: fleet.service
        command: start

Добавляю:

    - name: 00-eth0.network
      runtime: true
      content: |
        [Match]
        Name=enp0s3

        [Network]
        DNS=192.168.1.1
        Address=192.168.1.11/24
        Gateway=192.168.1.1

<br/>

    $ chmod +x coreos1-config-drive
    $ cp coreos1-config-drive coreos2-config-drive

<br/>

    $ vi coreos2-config-drive

Устанавливаю значение для параметра DEFAULT_ETCD_PEER_URLS

    DEFAULT_ETCD_PEER_URLS="http://192.168.1.12:2380"

и сетевой адаптер:

    Address=192.168.1.12/24

<br/>

Возможно, что и DEFAULT_ETCD_PEER_URLS можно задать таким способом, но у меня не получилось.

    $ ./coreos1-config-drive -H coreos1 -S ~/.ssh/id_rsa.pub -d https://discovery.etcd.io/126282ce7e06b79eae0d6e1d78c9c73c
    $ ./coreos2-config-drive -H coreos2 -S ~/.ssh/id_rsa.pub -d https://discovery.etcd.io/126282ce7e06b79eae0d6e1d78c9c73c

<br/>

### Запускаю виртуальные машины VirtualBox с CoreOS

Vdi диск подключаю как жесткий диск. ISO как CD-ROM.

Добавляю 1 сетевой адаптер типа Bridge и сообщаю, что он должен работать с локальным eh0.

Запускаю виртуальные машины.

Можно к ним теперь подключиться:

    $ ssh core@192.168.1.11
    $ ssh core@192.168.1.12

При обращении по адресу:

https://discovery.etcd.io/126282ce7e06b79eae0d6e1d78c9c73c

получаю 2 ноды.

    {"action":"get","node":{"key":"/_etcd/registry/126282ce7e06b79eae0d6e1d78c9c73c","dir":true,"nodes":[{"key":"/_etcd/registry/126282ce7e06b79eae0d6e1d78c9c73c/19a1d9a8d00f060b","value":"coreos1=http://192.168.1.11:2380","modifiedIndex":982060787,"createdIndex":982060787},{"key":"/_etcd/registry/126282ce7e06b79eae0d6e1d78c9c73c/aa4049b9a55f7765","value":"coreos2=http://192.168.1.12:2380","modifiedIndex":982061040,"createdIndex":982061040}],"modifiedIndex":982059692,"createdIndex":982059692}}
