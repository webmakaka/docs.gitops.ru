---
layout: page
title: Introduction to CoreOS Training Video - etcd And etcdctl
description: Introduction to CoreOS Training Video - etcd And etcdctl
keywords: Introduction to CoreOS Training Video, etcd And etcdctl
permalink: /devops/containers/coreos/introduction-to-coreos/launching-a-development-coreos-cluster/etcd_And_etcdctl/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Launching A Development CoreOS Cluster : etcd And etcdctl

### Interacting with ETCD

    $ etcdctl ls /
    /coreos.com

<br/>

    $ etcdctl get /coreos.com
    /coreos.com: is a directory

<br/>

    $ etcdctl ls / --recursive
    /coreos.com
    /coreos.com/network
    /coreos.com/network/config
    /coreos.com/network/subnets
    /coreos.com/network/subnets/10.1.22.0-24
    /coreos.com/network/subnets/10.1.7.0-24
    /coreos.com/network/subnets/10.1.68.0-24
    /coreos.com/updateengine
    /coreos.com/updateengine/rebootlock
    /coreos.com/updateengine/rebootlock/semaphore

<br/>

    $ etcdctl get /coreos.com/updateengine/rebootlock/semaphore
    {"semaphore":1,"max":1,"holders":null}

<br/>

    $ etcdctl -o extended get /coreos.com/updateengine/rebootlock/semaphore
    Key: /coreos.com/updateengine/rebootlock/semaphore
    Created-Index: 5
    Modified-Index: 5
    TTL: 0
    Index: 12383

    {"semaphore":1,"max":1,"holders":null}

<br/>

    $ etcdctl mkdir /my_data
    $ etcdctl ls / --recursive



    $ etcdctl mk /my_data/key myvalue

    $ etcdctl get /my_data/key
    myvalue

    $ etcdctl update /my_data/key myNewValue

    $ etcdctl get /my_data/key
    myNewValue

    $ etcdctl set /my_data/key2 mykey2

    $ etcdctl set /my_data/expiring_key byebye --ttl 5

    $ etcdctl rm /my_data/key

    $ etcdctl rm /my_data --recursive

<br/>

    core@core-01 ~ $ etcdctl watch /test/hello

    core@core-02 ~ $ etcdctl set /test/hello "hello world"
    hello world


    core@core-01 ~ $ etcdctl -o extended watch /test/hello --recursive

    core@core-01 ~ $ etcdctl exec-watch --recursive /foo -- sh -c "env | grep ETCD"

    core@core-02 ~ $ etcdctl set /foo/bar 1
    core@core-02 ~ $ etcdctl set /foo/bar2 2
