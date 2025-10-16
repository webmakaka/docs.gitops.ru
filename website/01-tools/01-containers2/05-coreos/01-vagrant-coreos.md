---
layout: page
title: Запуск CoreOS с помощью Vargrant
description: Запуск CoreOS с помощью Vargrant
keywords: Запуск CoreOS с помощью Vargrant
permalink: /devops/containers/coreos/vagrant-coreos/
---

# Запуск CoreOS с помощью Vargrant

VirtualBox и Git должны быть установлены.

### Vagrant и CoreOS

    $ cd ~
    $ git clone https://github.com/coreos/coreos-vagrant/

    $ cd coreos-vagrant/

    $ cp config.rb.sample config.rb
    $ cp user-data.sample user-data

<br/>

### Вариант 1: Vagrant – a three-node cluster with dynamic discovery

<br/>

    $ vi config.rb

Разкомментировать и установить:

    $num_instances=3

    $update_channel='stable'

<br/>

<!-- Генерируем
https://discovery.etcd.io/new

<br/>

    $ vi user-data

    discovery: https://discovery.etcd.io/29fb47f99d2b8ee4d10d0ce49f350a0f


<br/> -->

<br/>

    // Добавить ключ, чтобы ходить между нодами без ввода пароля
    $ ssh-add ~/.vagrant.d/insecure_private_key

<br/>

    $ vagrant up

<br/>

    $ vagrant status
    Current machine states:

    core-01                   running (virtualbox)
    core-02                   running (virtualbox)
    core-03                   running (virtualbox)

<br/>

    $ vagrant ssh core-01

<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    0346b6af...	172.17.8.102	-
    393ec9fd...	172.17.8.101	-
    ee7b2c90...	172.17.8.103	-

<br/>

    $ etcdctl member list
    4c79cf8a1f776026: name=393ec9fdb68b439b8b090ac310ba9169 peerURLs=http://172.17.8.101:2380 clientURLs=http://172.17.8.101:2379 isLeader=true
    4c7cc319bf6f6f6d: name=0346b6af2aef4f66b240d881d1ebaf19 peerURLs=http://172.17.8.102:2380 clientURLs=http://172.17.8.102:2379 isLeader=false
    7907f7d543d59f3e: name=ee7b2c90bcc443559de4306995e9be94 peerURLs=http://172.17.8.103:2380 clientURLs=http://172.17.8.103:2379 isLeader=false

<br/>

### Вариант 2: Vagrant – a three-node cluster with static discovery

    $ cd ~
    $ mkdir coreos
    $ cd coreos

    $ git clone https://github.com/coreos/coreos-vagrant/ node1

<br/>

<!-- $ cd node1/ -->

<!-- $ cp config.rb.sample config.rb -->
<!-- $ cp user-data.sample user-data -->

    $ cd ../

    $ cp -r  node1/ node2
    $ cp -r  node1/ node3

В файлах vagrant заменил название core и ip адрес.

    config.vm.hostname = "core-01"
    ip = "172.17.8.#{i+100}"

<br/>

    $ vi node1/user-data

<br/>

```
#cloud-config

coreos:
  etcd2:
    name: core-01
    initial-advertise-peer-urls: http://172.17.8.101:2380
    listen-peer-urls: http://172.17.8.101:2380
    listen-client-urls: http://172.17.8.101:2379,http://127.0.0.1:2379
    advertise-client-urls: http://172.17.8.101:2379
    initial-cluster-token: etcd-cluster-1
    initial-cluster: core-01=http://172.17.8.101:2380,core-02=http://172.17.8.102:2380,core-03=http://172.17.8.103:2380
    initial-cluster-state: new
  fleet:
    public-ip: $public_ipv4
  flannel:
    interface: $public_ipv4
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
```

<br/>

    $ vi node2/user-data

<br/>

```
#cloud-config

coreos:
  etcd2:
    name: core-02
    initial-advertise-peer-urls: http://172.17.8.102:2380
    listen-peer-urls: http://172.17.8.102:2380
    listen-client-urls: http://172.17.8.102:2379,http://127.0.0.1:2379
    advertise-client-urls: http://172.17.8.102:2379
    initial-cluster-token: etcd-cluster-1
    initial-cluster: core-01=http://172.17.8.101:2380,core-02=http://172.17.8.102:2380,core-03=http://172.17.8.103:2380
    initial-cluster-state: new
  fleet:
    public-ip: $public_ipv4
  flannel:
    interface: $public_ipv4
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
```

<br/>

      $ vi node3/user-data

<br/>

```
#cloud-config

coreos:
  etcd2:
    name: core-03
    initial-advertise-peer-urls: http://172.17.8.103:2380
    listen-peer-urls: http://172.17.8.103:2380
    listen-client-urls: http://172.17.8.103:2379,http://127.0.0.1:2379
    advertise-client-urls: http://172.17.8.103:2379
    initial-cluster-token: etcd-cluster-1
    initial-cluster: core-01=http://172.17.8.101:2380,core-02=http://172.17.8.102:2380,core-03=http://172.17.8.103:2380
    initial-cluster-state: new
  fleet:
    public-ip: $public_ipv4
  flannel:
    interface: $public_ipv4
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start

```

<br/>

    // на всех нодах
    $ vagrant up

<br/>

    $ etcdctl member list
    5252f86ede0659f1: name=core-02 peerURLs=http://172.17.8.102:2380 clientURLs=http://172.17.8.102:2379 isLeader=false
    82a769c1959a906c: name=core-01 peerURLs=http://172.17.8.101:2380 clientURLs=http://172.17.8.101:2379 isLeader=true
    919890b32e9e6285: name=core-03 peerURLs=http://172.17.8.103:2380 clientURLs=http://172.17.8.103:2379 isLeader=false

<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    072e8f27...	172.17.8.101	-
    4be20dc0...	172.17.8.102	-
    c4e78c9f...	172.17.8.103	-

<br/>

### Вариант 3: Vagrant – a production cluster with three master nodes and three worker nodes

Дискавери ключик должен быть одним и тем же на master и workers.

    $ cd ~
    $ mkdir coreos
    $ cd coreos

    $ git clone https://github.com/coreos/coreos-vagrant/ master
    $ cp -r master/ worker


    $ curl -w "\n" 'https://discovery.etcd.io/new?size=3'
    https://discovery.etcd.io/eba44f8d77f0c96e42d8cea0c23d0ba5

<br/>

**master**

    $ vi master/user-data

<br/>

```

#cloud-config

coreos:
  etcd2:
    discovery: https://discovery.etcd.io/a789492a48d3b72ade3e9fab20443664
    advertise-client-urls: http://$public_ipv4:2379
    initial-advertise-peer-urls: http://$private_ipv4:2380
    # listen on both the official ports and the legacy ports
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://$private_ipv4:2380,http://$private_ipv4:7001
  fleet:
      metadata: "role=master"
      public-ip: $public_ipv4
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start

```

<br/>

**worker**

<br/>

    $ vi worker/user-data

```
#cloud-config

coreos:
  etcd2:
    proxy: on
    # use the same discovery token as for master, these nodes will proxy to master
    discovery: https://discovery.etcd.io/a789492a48d3b72ade3e9fab20443664
    # listen on both the official ports and the legacy ports
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
  fleet:
    metadata: "role=worker"
    etcd_servers: "http://localhost:2379"
    public-ip: $public_ipv4
  locksmith:
    endpoint: "http://localhost:2379"
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start

```

<br/>

    $ vi master/Vagrantfile

<br/>

    $num_instances = 3
    $instance_name_prefix = "core-master"
    $update_channel = "stable"
    ip = "172.17.8.#{i+102}"

<br/>

    $ vi worker/Vagrantfile

<br/>

    $num_instances = 3
    $instance_name_prefix = "core-worker"
    $update_channel = "stable"
    ip = "172.17.8.#{i+105}"

<br/>

    $ vagrant up

<br/>

    $ vagrant ssh core-master-01

<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    113bdafd...	172.17.8.104	role=master
    3850b7c7...	172.17.8.106	role=worker
    6acbbc25...	172.17.8.105	role=master
    7fd2c16c...	172.17.8.103	role=master
    b5d971b8...	172.17.8.108	role=worker
    ee3e2e1b...	172.17.8.107	role=worker

<br/>

    $ etcdctl member list
    2adae0d9255f7305: name=113bdafda32c4224a9d6fbaafebafc70 peerURLs=http://172.17.8.104:2380 clientURLs=http://172.17.8.104:2379 isLeader=false
    77c7ff313654f14f: name=6acbbc25e6ca43a7951c2fd6142e690d peerURLs=http://172.17.8.105:2380 clientURLs=http://172.17.8.105:2379 isLeader=false
    db29d548a2d79d27: name=7fd2c16c8c1d4801a61e5e5bf5729031 peerURLs=http://172.17.8.103:2380 clientURLs=http://172.17.8.103:2379 isLeader=true

<br/>

    $ vagrant ssh core-worker-01

<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    113bdafd...	172.17.8.104	role=master
    3850b7c7...	172.17.8.106	role=worker
    6acbbc25...	172.17.8.105	role=master
    7fd2c16c...	172.17.8.103	role=master
    b5d971b8...	172.17.8.108	role=worker
    ee3e2e1b...	172.17.8.107	role=worker

<br/>

    $ etcdctl member list
    2adae0d9255f7305: name=113bdafda32c4224a9d6fbaafebafc70 peerURLs=http://172.17.8.104:2380 clientURLs=http://172.17.8.104:2379 isLeader=false
    77c7ff313654f14f: name=6acbbc25e6ca43a7951c2fd6142e690d peerURLs=http://172.17.8.105:2380 clientURLs=http://172.17.8.105:2379 isLeader=false
    db29d548a2d79d27: name=7fd2c16c8c1d4801a61e5e5bf5729031 peerURLs=http://172.17.8.103:2380 clientURLs=http://172.17.8.103:2379 isLeader=true
