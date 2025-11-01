---
layout: page
title: Какие-то старые записи по Docker Swarm (устаревшие, позде будут выпилены)
description: Какие-то старые записи по Docker Swarm (устаревшие, позде будут выпилены)
keywords: devops, docker, Какие-то старые записи по Docker Swarm (устаревшие, позде будут выпилены)
permalink: /devops/containers/docker/clustering/swarm/old/
---

# Какие-то старые записи по Docker Swarm (устаревшие, позде будут выпилены)

Но некоторые команды возможно понадобятся, поэтому и не удаляю.

### strategy

**strategy random**

    swarm manage token://<token> -H 0.0.0.0:4243 --strategy random &

стартуем 20 контейнеров. Они должны разместить произвольно на хостах.

    $ for i in {1..20}; do /bin/bash -c "docker run -d nginx"; done

удаляем

    $ docker rm -f $(docker ps -aq)

<br/>

**strategy binpacking** (default) (в зависимости от памяти хост машины)

убили swarm процесс

    swarm manage token://<token> -H 0.0.0.0:4243 --strategy binpacking &

<br/>

**Affinity filter**

    docker run -d --name c1 -e constraint:node==three nginx
    docker run -d --name c2 -e constraint:node==two nginx

    docker run -d --name c4 -e affinity:container==c1 nginx
    docker run -d --name c5 -e affinity:container!=c1 nginx

<br/>

**Standard Constraints**

    docker -H two:2375 info

    docker run -d --name c1 -e constraint:operatingsystem==Deb* nginx
    docker run -d --name c2 -e constraint:operatingsystem==fedora* nginx (Ошибка!)

<br/>

**Custom Constraints**

two:

    vi /etc/default/docker

    DOCKER_OPTS="-H 192.168.56.35:2375 -H unix:///var/run/docker.sock --label zone=dmz --label site=london"

    service docker restart
    docker -H two:2375 info
    (появились label)

three:

    vi /etc/default/docker

    DOCKER_OPTS="-H 192.168.56.185:2375 -H unix:///var/run/docker.sock --label zone=prod --label site=london"
    service docker restart
    docker -H three:2375 info

two:

    docker run -d --name londprod1 -e constraint:site==london -e constraint:zone==prod nginx
    docker ps

    docker run -d --name londprod2 -e constraint:site==london -e constraint:zone!=prod nginx
    docker ps

<br/>

**Resourse Constraints**

    docker run -d -p 8080:80 nginx
    docker run -d -p 8080:80 nginx
    docker run -d -p 8080:80 nginx

на каждом из хостов создаст по контейнеру.
Если попытаться выполнить команду 4-й раз получим ошибку, т.к. ресурсов больше нет.

<br/>

### Пример

    $ docker-machine create --driver virtualbox dev1

    $ eval "$(docker-machine env dev1)"

    $ docker pull swarm

    $ docker run swarm -v
    swarm version 1.1.3 (7e9c6bd)

<br/>

### Create a Cluster

    $ sid=$(docker run swarm create)

    $ echo $sid
    d3af6d950956757646273019a8792b53

<br/>

### Create the Swarm Manager

    $ docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery token://$sid swarm-master

    $ docker-machine ls
    NAME           ACTIVE   DRIVER       STATE     URL                         SWARM                   DOCKER    ERRORS
    swarm-master   -        virtualbox   Running   tcp://192.168.99.100:2376   swarm-master (master)   v1.10.3


    $ eval "$(docker-machine env swarm-master)"

    $ docker-machine ls
    NAME           ACTIVE   DRIVER       STATE     URL                         SWARM                   DOCKER    ERRORS
    swarm-master   *        virtualbox   Running   tcp://192.168.99.100:2376   swarm-master (master)   v1.10.3


    $ docker info

<br/>

### Create Swarm Nodes

<br/>

    $ docker-machine create -d virtualbox --engine-label itype=frontend --swarm --swarm-discovery token://$sid swarm-node-01

    $ docker-machine create -d virtualbox --swarm --swarm-discovery token://$sid swarm-node-02

    $ docker-machine create -d virtualbox --swarm --swarm-discovery token://$sid swarm-node-03

    $ docker-machine ls
    NAME            ACTIVE   DRIVER       STATE     URL                         SWARM                   DOCKER    ERRORS
    swarm-master    *        virtualbox   Running   tcp://192.168.99.100:2376   swarm-master (master)   v1.10.3
    swarm-node-01   -        virtualbox   Running   tcp://192.168.99.101:2376   swarm-master            v1.10.3
    swarm-node-02   -        virtualbox   Running   tcp://192.168.99.102:2376   swarm-master            v1.10.3
    swarm-node-03   -        virtualbox   Running   tcp://192.168.99.103:2376   swarm-master            v1.10.3

<br/>

    $ docker-machine env --swarm swarm-master   # (checkout the different port)

    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.99.100:3376"
    export DOCKER_CERT_PATH="/home/marley/.docker/machine/machines/swarm-master"
    export DOCKER_MACHINE_NAME="swarm-master"
    # Run this command to configure your shell:
    # eval $(docker-machine env --swarm swarm-master)

<br/>

    $ eval "$(docker-machine env --swarm swarm-master)"

    $ docker-machine ls    (Notice non of the docker machines have the asterick)

<br/>

    $ docker info
    Containers: 5
    Images: 4
    Server Version: swarm/1.1.3
    Role: primary
    Strategy: spread
    Filters: health, port, dependency, affinity, constraint
    Nodes: 4
     swarm-master: 192.168.99.100:2376
      └ Status: Healthy
      └ Containers: 2
      └ Reserved CPUs: 0 / 1
      └ Reserved Memory: 0 B / 1.021 GiB
      └ Labels: executiondriver=native-0.2, kernelversion=4.1.19-boot2docker, operatingsystem=Boot2Docker 1.10.3 (TCL 6.4.1); master : 625117e - Thu Mar 10 22:09:02 UTC 2016, provider=virtualbox, storagedriver=aufs
      └ Error: (none)
      └ UpdatedAt: 2016-04-09T23:11:51Z
     swarm-node-01: 192.168.99.101:2376
      └ Status: Healthy
      └ Containers: 1
      └ Reserved CPUs: 0 / 1
      └ Reserved Memory: 0 B / 1.021 GiB
      └ Labels: executiondriver=native-0.2, itype=frontend, kernelversion=4.1.19-boot2docker, operatingsystem=Boot2Docker 1.10.3 (TCL 6.4.1); master : 625117e - Thu Mar 10 22:09:02 UTC 2016, provider=virtualbox, storagedriver=aufs
      └ Error: (none)
      └ UpdatedAt: 2016-04-09T23:12:33Z
     swarm-node-02: 192.168.99.102:2376
      └ Status: Healthy
      └ Containers: 1
      └ Reserved CPUs: 0 / 1
      └ Reserved Memory: 0 B / 1.021 GiB
      └ Labels: executiondriver=native-0.2, kernelversion=4.1.19-boot2docker, operatingsystem=Boot2Docker 1.10.3 (TCL 6.4.1); master : 625117e - Thu Mar 10 22:09:02 UTC 2016, provider=virtualbox, storagedriver=aufs
      └ Error: (none)
      └ UpdatedAt: 2016-04-09T23:12:27Z
     swarm-node-03: 192.168.99.103:2376
      └ Status: Healthy
      └ Containers: 1
      └ Reserved CPUs: 0 / 1
      └ Reserved Memory: 0 B / 1.021 GiB
      └ Labels: executiondriver=native-0.2, kernelversion=4.1.19-boot2docker, operatingsystem=Boot2Docker 1.10.3 (TCL 6.4.1); master : 625117e - Thu Mar 10 22:09:02 UTC 2016, provider=virtualbox, storagedriver=aufs
      └ Error: (none)
      └ UpdatedAt: 2016-04-09T23:12:05Z
    Kernel Version: 4.1.19-boot2docker
    Operating System: linux
    CPUs: 4
    Total Memory: 4.085 GiB
    Name: swarm-master

<br/>

    $ docker run swarm list token://$sid
    192.168.99.103:2376
    192.168.99.102:2376
    192.168.99.101:2376
    192.168.99.100:2376

<br/>

    $ docker ps     #(no containers are running in the swarm)

<br/>

Look at the Four Nodes

    $ docker-machine ls

    $ eval "$(docker-machine env swarm-master)"

<br/>

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
    f15c66f10765        swarm:latest        "/swarm join --advert"   17 minutes ago      Up 17 minutes                           swarm-agent
    4f81fcef587e        swarm:latest        "/swarm manage --tlsv"   17 minutes ago      Up 17 minutes                           swarm-agent-master

<br/>

    $ eval "$(docker-machine env swarm-node-01)"

<br/>

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
    8891322a859d        swarm:latest        "/swarm join --advert"   10 minutes ago      Up 10 minutes                           swarm-agent

<br/>

    $ eval "$(docker-machine env swarm-node-02)"

    $ docker ps

    $ eval "$(docker-machine env swarm-node-03)"

    $ docker ps

<br/>

Running Docker Instances with Swarm (explain Spead vs Binpack

    $ eval "$(docker-machine env --swarm swarm-master)"

    $ docker ps

    $ docker run -itd --name engmgr ubuntu

<br/>

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    f0c59feb6763        ubuntu              "/bin/bash"         26 seconds ago      Up 23 seconds                           swarm-node-02/engmgr

<br/>

    $ for i in `seq 1 6`; do docker run -itd -e constraint:itype!=frontend --name eng$i ubuntu; done

<br/>

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    5b762f03d416        ubuntu              "/bin/bash"         9 seconds ago       Up 6 seconds                            swarm-node-03/eng6
    f301111c7433        ubuntu              "/bin/bash"         9 seconds ago       Up 7 seconds                            swarm-node-02/eng5
    523de40a66fe        ubuntu              "/bin/bash"         10 seconds ago      Up 7 seconds                            swarm-node-03/eng4
    3eafa9495a09        ubuntu              "/bin/bash"         10 seconds ago      Up 7 seconds                            swarm-node-02/eng3
    07a6c7bde575        ubuntu              "/bin/bash"         11 seconds ago      Up 8 seconds                            swarm-master/eng2
    5c64c2a5621c        ubuntu              "/bin/bash"         32 seconds ago      Up 30 seconds                           swarm-node-03/eng1
    f0c59feb6763        ubuntu              "/bin/bash"         2 minutes ago       Up 2 minutes                            swarm-node-02/engmgr

<br/>

    $ docker run -itd --name engmgr-c -e affinity:container==engmgr ubuntu

<br/>

Cleanup

    $ docker-machine kill $(docker-machine ls -q)

    $ docker-machine rm $(docker-machine ls -q)
