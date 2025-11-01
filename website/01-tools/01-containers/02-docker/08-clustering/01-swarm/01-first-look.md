---
layout: page
title: Docker Swarm первый взгляд
description: Docker Swarm первый взгляд
keywords: devops, docker, Docker Swarm первый взгляд
permalink: /devops/containers/docker/clustering/swarm/first-look/
---

# Docker Swarm первый взгляд

<br/>

Делаю:  
15.02.2018

<br/>

**ПО**

- <a href="//sysadm.ru/server/linux/virtual/vagrant/">Vagrant</a>
- <a href="/tools/git/">git</a>

<br/>

**Файлы для старта виртуальных машин с coreos**  
https://bitbucket.org/sysadm-ru/native-docker-clustering

<br/>

Файлы готовил не я. Ну да ладно.

<br/>

    $ mkdir ~/docker-swarm-scripts
    $ cd ~/docker-swarm-scripts
    $ git clone https://bitbucket.org/sysadm-ru/native-docker-clustering
    $ cd native-docker-clustering
    $ vagrant box update
    $ vagrant up

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

Работаю с первыми 3 виртуальными машинами, на остальные предлагаю забить.

    $ vagrant ssh core-01
    $ vagrant ssh core-02
    $ vagrant ssh core-03

<br/>

Делаем:

    core-01 - manager1 (172.17.8.101)
    core-02 - worker1  (172.17.8.102)
    core-03 - worker2  (172.17.8.103)

<br/>

На всех:

    $ docker pull swarm

    $ docker run swarm -v
    swarm version 1.2.8 (48d86b1)

<br/>

### core-01

    $ docker swarm init --advertise-addr <MANAGER-IP>

    $ docker swarm init --advertise-addr 172.17.8.101
    Swarm initialized: current node (1j517f9tyh969t51ap4uzknc4) is now a manager.

    To add a worker to this swarm, run the following command:

        docker swarm join \
        --token SWMTKN-1-2pz4il4gexlaan2ik825mr5xdxmpllbqxhmhhf6x6z8kvcf889-ekfm7so78lcqgy06eqvanudcg \
        172.17.8.101:2377

    To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

<br/>

### core-02, core-03, ....

    $ docker swarm join \
    --token SWMTKN-1-2pz4il4gexlaan2ik825mr5xdxmpllbqxhmhhf6x6z8kvcf889-ekfm7so78lcqgy06eqvanudcg \
    172.17.8.101:2377

<br/>

### core-01

    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
    jy14pbjj9e6hfm7ltebjg68oy *   core-01             Ready               Active              Leader
    5bant3omhyf5pjmft849b70gd     core-02             Ready               Active
    v9k79tqie9oos1x9sytr3vvw3     core-03             Ready               Active

<br/>

### Create a service

<br/>

    $ docker service create \
      --name=viz \
      --publish=8080:8080/tcp \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/>

    -- если нужно будет удалить
    $ docker service rm viz

<br/>

    $ docker service scale viz=10

<br/>

    $ docker service ps viz
    ID                  NAME                IMAGE                             NODE                DESIRED STATE       CURRENT STATE                ERROR               PORTS
    ba11rp3bfn9t        viz.1               dockersamples/visualizer:latest   core-02             Running             Running about a minute ago
    j9tp5lfp930c        viz.2               dockersamples/visualizer:latest   core-01             Running             Running 55 seconds ago
    t5zpsoshkvg2        viz.3               dockersamples/visualizer:latest   core-02             Running             Running 57 seconds ago
    nju79l93cdxh        viz.4               dockersamples/visualizer:latest   core-03             Running             Running 33 seconds ago
    n21y9evs773b        viz.5               dockersamples/visualizer:latest   core-01             Running             Running 55 seconds ago
    upd0ajc2679m        viz.6               dockersamples/visualizer:latest   core-02             Running             Running 57 seconds ago
    z7pwn0toygjk        viz.7               dockersamples/visualizer:latest   core-01             Running             Running 56 seconds ago
    mcfqzprv3kbp        viz.8               dockersamples/visualizer:latest   core-03             Running             Running 33 seconds ago
    14m0p2dbt6e7        viz.9               dockersamples/visualizer:latest   core-03             Running             Running 33 seconds ago
    e94x2rbahfit        viz.10              dockersamples/visualizer:latest   core-03             Running             Running 36 seconds ago

<br/>

http://172.17.8.101:8080/

<br/>

![Визуализация Docker Swarm](/img/devops/containers//docker/clustering/swarm/swarm-visualizer.png 'Визуализация Docker Swarm'){: .center-image }

<br/>

Конечно, такое количество запущенных контейнеров с однотипными задачами, в данном случае, избыточно.
