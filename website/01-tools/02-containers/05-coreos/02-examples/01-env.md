---
layout: page
title: Подготовка окружения для запуска coreos
permalink: /devops/containers/coreos/example/env/
---


# Подготовка окружения для запуска coreos


<br/>

**Для запуска примеров нужно:**


1) Установить virtualbox  
2) Установить vagrant


<br/>

### Vagrantfile и user-data


<br/>

    $ cd ~
    $ git clone https://github.com/sysadm-ru/coreos-docker-examples
    $ cd coreos-docker-examples/01/


<br/>

Сгенерировать ключ:

https://discovery.etcd.io/new?size=7

    $ vi user-data

Заменить сгенерированным ключом.

    discovery: https://discovery.etcd.io/89e341b6012e47d7e6654eea7b882418


<br/>

После каждого vagrant destroy нужно обновлять discovery.

<br/>

    $ vagrant box update


<br/>

    $ vagrant up

<br/>


// Чтобы можно было по ssh ходить между узлами без пароля

  $ ssh-add ~/.vagrant.d/insecure_private_key


<br/>

    $ vagrant status
    Current machine states:

    core-01                   running (virtualbox)
    core-02                   running (virtualbox)
    core-03                   running (virtualbox)
    core-04                   running (virtualbox)
    core-05                   running (virtualbox)
    core-06                   running (virtualbox)
    core-07                   running (virtualbox)


<br/>

    $ vagrant ssh core-01


<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    010edf2c...	172.17.8.107	-
    0f1619f3...	172.17.8.101	-
    2320be18...	172.17.8.106	-
    43425159...	172.17.8.103	-
    6c66d6fb...	172.17.8.102	-
    98b5dead...	172.17.8.105	-
    e45abe65...	172.17.8.104	-
