---
layout: page
title: Основные сервисы CoreOS
description: Основные сервисы CoreOS
keywords: Основные сервисы CoreOS
permalink: /devops/containers/coreos/services/
---

# Основные сервисы CoreOS

<br/>

### Etcd

<br/>

Etcd — распределенное Key-Value хранилище, которое запускается на каждой машине кластера CoreOS и обеспечивает общий доступ практически ко всем данным в масштабе всего кластера. Внутри etcd хранятся настройки служб, их текущие состояние, конфигурация самого кластера и т.д. Etcd позволяет хранить данные иерархически (хранилище древовидно), подписываться на изменения ключей или целых директорий, задавать для ключей и директорий ключей значения TTL (фактически, «экспирить» их), атомарно изменять или удалять ключи, упорядоченно хранить их (что позволяет реализовывать своеобразные очереди). Поскольку конфигурация сервисов, запущенных в масштабе кластера, хранится в etcd, узнать о запуске и остановке того или иного сервиса можно просто подписавшись на изменения соответствующих ключей в хранилище.

Etcd - похоже на Consul и ZooKeeper. (Лично я ничего из этого пока не знаю).

<br/>

    $ etcdctl set /message Hello
    $ etcdctl get /message
    $ etcdctl mkdir /foo-service
    $ etcdctl set /foo-service/container1 localhost:1111
    $ etcdctl ls /foo-service
    $ etcdctl set /foo "Expiring Soon" --ttl 20
    $ etcdctl watch /foo-service --recursive

    $ etcdctl cluster-health
    member 29dac19a68d1b860 is healthy: got healthy result from http://172.17.8.101:2379
    member b5e1282b428f7211 is healthy: got healthy result from http://172.17.8.103:2379
    member ecd0a5d052505a2f is healthy: got healthy result from http://172.17.8.102:2379
    cluster is healthy

<br/>

![etcd](/img/devops/containers/coreos/etcd.png 'etcd'){: .center-image }

<br/>

<br/>

![coreos cluster](/img/devops/containers/coreos/getting-started-with-coreos/pic1.png 'coreos cluster'){: .center-image }

<br/>

![coreos cluster](/img/devops/containers/coreos/getting-started-with-coreos/pic2.png 'coreos cluster'){: .center-image }

<br/>

**Аналоги:**

-   consul
-   ZooKeeper

<br/>

### Fleet

Fleet — (коротко и упрощенно - distributed systemd) это «надстройка» над systemd, которая переносит управление службами с локальной машины на уровень кластера. Fleet хранит конфигурацию служб в виде юнитов systemd (в etcd), автоматически доставляет ее на локальные машины, запускает, перезапускает (при необходимости), останавливает службы на машинах кластера. Fleet умеет планировать запуск служб исходя из загруженности конкретных машин кластера. Ему можно сказать, что конкретную службу нужно запускать только на определенных машинах и т.д.

<br/>

![fleetctl](/img/devops/containers/coreos/getting-started-with-coreos/pic3.png 'fleetctl'){: .center-image }

<br/>

    $ fleetctl list-machines
    $ fleetctl start redis.service
    $ fleetctl journal redis.service
    $ fleetctl --tunnel=10.2.1.1 list-machines

<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    20fd3ecb...	172.17.8.102	-
    89e20c71...	172.17.8.103	-
    d8ed170f...	172.17.8.101	-

<br/>

    $ fleetctl list-units
    UNIT	MACHINE	ACTIVE	SUB


    $ fleetctl --tunnel 127.0.0.1:2222 list-machines

    $ export FLEETCTL_TUNNEL="127.0.0.1:2222"

    $ fleetctl list-machines

<br/>

Let's overview the specific options of fleet for the [X-Fleet] section:

<br/>

    •	 MachineID : This unit will be scheduled on the machine identified by a given string.
    •	 MachineOf : This limits eligible machines to the one that hosts a specific unit.
    •	 MachineMetadata : This limits eligible machines to those hosts with this specific metadata.
    •	 Conflicts : This prevents a unit from being collocated with other units using glob-matching on other unit names.
    •	 Global : Schedule this unit on all machines in the cluster. A unit is considered invalid if options other than MachineMetadata are provided alongside Global=true.

<br/>

Fleetctl commands:

    1.	 Checking the status of the unit:
    $ fleetctl status hello1.service

    2.	 Stopping the service:
    $ fleetctl stop hello1.service

    3.	 Viewing the service file:
    $ fleetctl cat hello1.service

    4.	 If you want to just upload the unit file:
    $ fleetctl submit hello1.service

    5.	 Listing all running fleet units:
    $ fleetctl list-units

    6.	 Listing fleet cluster machines:
    $ fleetctl list-machines

<br/>

**Аналоги:**

-   Kubernetes - более продвинутый аналог fleet

<br/>

### Flannel

flannel - виртуальная сеть, которая предоставляет подсеть, чтобы контейнеры могли между собой обмениваться пакетами. (я так перевел / понял)

![fleetctl](/img/devops/containers/coreos/getting-started-with-coreos/pic5.png 'fleetctl'){: .center-image }

<br/>

<br/>

![fleetctl](/img/devops/containers/coreos/getting-started-with-coreos/pic6.png 'fleetctl'){: .center-image }

<br/>

![fleetctl](/img/devops/containers/coreos/getting-started-with-coreos/pic7.png 'fleetctl'){: .center-image }

<br/>

### journalctl

Показывает логи

    # journalctl -u hello.service
    # journalctl -f -u hello.service


    $ journalctl --unit etcd.service --no-pager


    $ journalctl :	This lists the combined	journal	log	from all the sources.

    $ journalctl –u	etcd2.service :	This lists the logs from etcd2.service .

    $ journalctl –u	etcd2.service –f : This lists the	logs from etcd2. service like tail –f format.

    $ journalctl –u	etcd2.service –n 100 :	This lists	the	logs of	the	last 100 lines.

    $ journalctl –u	etcd2.service –no-pager :	This	lists the logs with	no	pagination,
    which is useful	for	search.

    $ journalctl –p	err	–n	100 : This lists	all	100	errors by filtering the logs.

    $ journalctl -u	etcd2.service —since today : This lists today’s logs of etcd2.service.

    $ journalctl -u	etcd2.service -o json-pretty :	This lists the logs of etcd2.service in JSON-formatted output.

<br/>

### Important files and directories

-   Knowing these files and directories helps with debugging the issues:

-   Systemd unit file location - /usr/lib64/systemd/system .

-   Network unit files - /usr/lib64/systemd/network .

-   User-written unit files and drop-ins to change the default parameters -
    /etc/systemd/system . Drop-ins for specific configuration changes can be done
    using the configuration file under the specific service directory. For example, to
    modify the fleet configuration, create the fleet.service.d directory and put the
    configuration file in this directory.

-   User-written network unit files - /etc/systemd/network .

-   Runtime environment variables and drop-in configuration of individual components
    such as etcd and fleet - /run/systemd/system/ .

-   The vagrantfile user data containing the cloud-config user data used with Vagrant - /var/lib/coreos-vagrant .

-   The systemd-journald logs - /var/log/journal .

-   cloud-config.yaml associated with providers such as Vagrant, AWS, and GCE-
    /usr/share/oem . (CoreOS first executes this cloud-config and then executes the
    user-provided cloud-config .)

-   Release channel and update strategy - /etc/coreos/update.conf .

-   The public and private IP address ( COREOS_PUBLIC_IPV4 and COREOS_PRIVATE_IPV4 )

*   /etc/environment .

-   The machine ID for the particular CoreOS node - /etc/machine-id .

-   The flannel network configuration - /run/flannel/ .
