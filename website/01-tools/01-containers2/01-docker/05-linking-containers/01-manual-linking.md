---
layout: page
title: Пример линковки контейнеров для их совместной работы
description: Пример линковки контейнеров для их совместной работы
keywords: devops, docker, Пример линковки контейнеров для их совместной работы
permalink: /devops/containers/docker/linking-containers/manual-linking/
---

# Пример линковки контейнеров для их совместной работы

**!!! Было актуально когда-то давно**

<strong>Создаем контейнер с сервером</strong>

    vi Dockerfile

<br/>

    FROM centos:centos6
    RUN yum -y install mysql-server
    RUN touch /etc/sysconfig/network

    RUN service mysqld start &&  \
     	sleep 5s && \
    	mysql -e "GRANT ALL ON *.* to 'root'@'%'; FLUSH PRIVILEGES"

    EXPOSE 3306
    CMD ["/usr/bin/mysqld_safe"]

<br/>

    $ docker build -rm -t centos6/mysql_server:v01 .

<br/>

    $ docker run -t -i --name mysql_server 96200d183cc5


    96200d183cc5  - сгенерированный id созданного имиджа.

<br/>

### Создаем контейнер с клиентом

    vi Dockerfile

<br/>

    FROM centos:centos6

    RUN yum -y install mysql

    CMD ["bash"]

<br/>

    $ docker build -rm -t centos6/mysql_client:v01 .

<br/>

--link name:alias

Where name is the name of the container we're linking to and alias is an alias for the link name.

    $ docker run -t -i --link mysql_server:mysql_server 4a173a15faa5

<br/>

    # env
    HOSTNAME=71ff5486e03a
    TERM=xterm
    MYSQL_SERVER_PORT_3306_TCP=tcp://172.17.1.14:3306
    MYSQL_SERVER_PORT_3306_TCP_PORT=3306
    MYSQL_SERVER_PORT=tcp://172.17.1.14:3306
    MYSQL_SERVER_PORT_3306_TCP_ADDR=172.17.1.14
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    PWD=/
    SHLVL=1
    HOME=/
    MYSQL_SERVER_NAME=/clever_bartik/mysql_server
    MYSQL_SERVER_PORT_3306_TCP_PROTO=tcp
    _=/usr/bin/env

<br/>

    # cat /etc/hosts
    172.17.1.15	71ff5486e03a
    127.0.0.1	localhost
    ::1	localhost ip6-localhost ip6-loopback
    fe00::0	ip6-localnet
    ff00::0	ip6-mcastprefix
    ff02::1	ip6-allnodes
    ff02::2	ip6-allrouters
    172.17.1.14	mysql_server

<br/>

Взято:  
http://alexecollins.com/docker-linking-containers/

https://docs.docker.com/userguide/dockerlinks/#docker-container-linking

<!--

<br/>

###


    src - source
    rcvr - reciever
    ali-src - alias

    docker run --name=src -d img

    docker run --name=rcvr --link=src:ali-src -it ubuntu:15.04 /bin/bash


    docker inspect rcvr

    docker attach rcvr
    env
    env | grep ALI
    cat /etc/hosts

-->
