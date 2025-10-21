---
layout: page
title: Native Docker Clustering > Securing your Swarm Cluster
description: Native Docker Clustering > Securing your Swarm Cluster
keywords: devops, containers, docker, clustering, swarm, securing your swarm cluster
permalink: /devops/containers/docker/clustering/swarm/native-docker-clustering/securing-your-swarm-cluster/
---

# Docker Swarm: Native Docker Clustering [2016, ENG] > Module 5: Securing your Swarm Cluster

<br/>

![Native Docker Clustering](/img/devops/containers//docker/clustering/swarm/native-docker-clustering/pic3.png 'Native Docker Clustering'){: .center-image }

<br/>

### ОШИБКИ. НЕ МОГУ НОРМАЛЬНО РАБОТАТЬ С SSH в VAGRANT. Смогу продолжить, не раньше, чем побежу проблемы.

ПОДРОБНЕЕ ЗДЕСЬ:  
https://linuxforum.ru/viewtopic.php?id=38509

Так. Удалось найти обходной путь. На выходных или даже раньше попробую развернуть.

<br/>

Подготовил с помощью следующего vagrant скрипта <a href="//sysadm.ru/server/linux/virtual/vagrant/for-docker-swarm/"></a>следующее:

    192.168.56.101 client
    192.168.56.102 ca
    192.168.56.103 manager1
    192.168.56.104 manager2
    192.168.56.105 manager3
    192.168.56.106 node1
    192.168.56.107 node2
    192.168.56.108 node3

<br/>

### CREATE CA

<br/>

    $ vagrant ssh ca

    $ sudo su -

    # mkdir -p /home/debian/certs/
    # cd /home/debian/certs/

    # openssl genrsa -out ca-key.pem 2048

    # ls
    ca-key.pem


    # openssl req -config /usr/lib/ssl/openssl.cnf -new -key ca-key.pem -x509 -days 1825 -out ca-cert.pem

    Country Name (2 letter code) [AU]:UK
    State or Province Name (full name) [Some-State]:CH
    Locality Name (eg, city) []:Sunderland
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:
    Organizational Unit Name (eg, section) []:
    Common Name (e.g. server FQDN or YOUR name) []:
    Email Address []:

    # ls
    ca-cert.pem  ca-key.pem

<br/>

### CREATE MANAGER AND NODE KEYS

    # openssl genrsa -out manager1-key.pem 2048
    # openssl req -subj "/CN=manager1" -new -key manager1-key.pem -out manager1.csr
    # echo subjectAltName = IP:192.168.56.103,IP:127.0.0.1 > extfile.cnf
    # openssl x509 -req -days 365 -in manager1.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out manager1-cert.pem -extfile extfile.cnf

<br/>

    # openssl genrsa -out manager2-key.pem 2048
    # openssl req -subj "/CN=manager2" -new -key manager2-key.pem -out manager2.csr
    # echo subjectAltName = IP:192.168.56.104,IP:127.0.0.1 > extfile.cnf
    # openssl x509 -req -days 365 -in manager2.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out manager2-cert.pem -extfile extfile.cnf

<br/>

    # openssl genrsa -out manager3-key.pem 2048
    # openssl req -subj "/CN=manager3" -new -key manager3-key.pem -out manager3.csr
    # echo subjectAltName = IP:192.168.56.105,IP:127.0.0.1 > extfile.cnf
    # openssl x509 -req -days 365 -in manager3.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out manager3-cert.pem -extfile extfile.cnf

<br/>

    # openssl genrsa -out node1-key.pem 2048
    # openssl req -subj "/CN=node1" -new -key node1-key.pem -out node1.csr
    # echo subjectAltName = IP:192.168.56.106,IP:127.0.0.1 > extfile.cnf
    # openssl x509 -req -days 365 -in node1.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out node1-cert.pem -extfile extfile.cnf

<br/>

    # openssl genrsa -out node2-key.pem 2048
    # openssl req -subj "/CN=node2" -new -key node2-key.pem -out node2.csr
    # echo subjectAltName = IP:192.168.56.107,IP:127.0.0.1 > extfile.cnf
    # openssl x509 -req -days 365 -in node2.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out node2-cert.pem -extfile extfile.cnf

<br/>

    # openssl genrsa -out node3-key.pem 2048
    # openssl req -subj "/CN=node3" -new -key node3-key.pem -out node3.csr
    # echo subjectAltName = IP:192.168.56.108,IP:127.0.0.1 > extfile.cnf
    # openssl x509 -req -days 365 -in node3.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out node3-cert.pem -extfile extfile.cnf

<br/>

### CREATE CLIENT KEYS

    # openssl genrsa -out client-key.pem 2048
    # openssl req -subj "/CN=client" -new -key client-key.pem -out client.csr
    # echo extendedKeyUsage = clientAuth > extfile.cnf
    # openssl x509 -req -days 365 -in client.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -extfile extfile.cnf

<br/>

    # ls -l
    total 100
    -rw-r--r-- 1 root root 1261 Feb 12 11:50 ca-cert.pem
    -rw-r--r-- 1 root root   17 Feb 12 12:06 ca-cert.srl
    -rw-r--r-- 1 root root 1675 Feb 12 11:49 ca-key.pem
    -rw-r--r-- 1 root root 1099 Feb 12 12:02 client-cert.pem
    -rw-r--r-- 1 root root  887 Feb 12 12:02 client.csr
    -rw-r--r-- 1 root root 1679 Feb 12 12:01 client-key.pem
    -rw-r--r-- 1 root root   48 Feb 12 12:06 extfile.cnf
    -rw-r--r-- 1 root root 1103 Feb 12 12:06 manager1-cert.pem
    -rw-r--r-- 1 root root  891 Feb 12 12:04 manager1.csr
    -rw-r--r-- 1 root root 1679 Feb 12 12:04 manager1-key.pem
    -rw-r--r-- 1 root root 1103 Feb 12 11:58 manager2-cert.pem
    -rw-r--r-- 1 root root  891 Feb 12 11:58 manager2.csr
    -rw-r--r-- 1 root root 1679 Feb 12 11:58 manager2-key.pem
    -rw-r--r-- 1 root root 1103 Feb 12 11:59 manager3-cert.pem
    -rw-r--r-- 1 root root  891 Feb 12 11:58 manager3.csr
    -rw-r--r-- 1 root root 1675 Feb 12 11:58 manager3-key.pem
    -rw-r--r-- 1 root root 1099 Feb 12 12:00 node1-cert.pem
    -rw-r--r-- 1 root root  887 Feb 12 12:00 node1.csr
    -rw-r--r-- 1 root root 1679 Feb 12 12:00 node1-key.pem
    -rw-r--r-- 1 root root 1099 Feb 12 12:01 node2-cert.pem
    -rw-r--r-- 1 root root  887 Feb 12 12:00 node2.csr
    -rw-r--r-- 1 root root 1679 Feb 12 12:00 node2-key.pem
    -rw-r--r-- 1 root root 1099 Feb 12 12:01 node3-cert.pem
    -rw-r--r-- 1 root root  887 Feb 12 12:01 node3.csr
    -rw-r--r-- 1 root root 1675 Feb 12 12:01 node3-key.pem

<br/>

### COPY KEYS

    На нодах сначала нужно создать .docker

    mkdir .docker
    chmod 777 .docker/


    # scp ./ca-cert.pem ubuntu@manager1:/home/ubuntu/.docker/ca.pem

<br/>

**Manager1**

    $ vagrant ssh manager1
    $ sudo su -

    $ adduser debian
    # su - debian

    $ mkdir ~/.docker
    $ chmod 777 ~/.docker/

c CA

    # scp ./ca-cert.pem debian@manager1:/home/debian/.docker/ca.pem

    # scp ./manager1-cert.pem ubuntu@manager1:/home/ubuntu/.docker/cert.pem

    # scp ./manager1-key.pem ubuntu@manager1:/home/ubuntu/.docker/key.pem

<br/>

**Manager2**

    # scp ./ca-cert.pem ubuntu@manager2:/home/ubuntu/.docker/ca.pem

    # scp ./manager2-cert.pem ubuntu@manager2:/home/ubuntu/.docker/cert.pem

    # scp ./manager2-key.pem ubuntu@manager2:/home/ubuntu/.docker/key.pem

<br/>

**Manager3**

    # scp ./ca-cert.pem ubuntu@manager3:/home/ubuntu/.docker/ca.pem

    # scp ./manager3-cert.pem ubuntu@manager3:/home/ubuntu/.docker/cert.pem

    # scp ./manager3-key.pem ubuntu@manager3:/home/ubuntu/.docker/key.pem

<br/>

**Node1**

    # scp ./ca-cert.pem ubuntu@node1:/home/ubuntu/.docker/ca.pem

    # scp ./node1-cert.pem ubuntu@node1:/home/ubuntu/.docker/cert.pem

    # scp ./node1-key.pem ubuntu@node1:/home/ubuntu/.docker/key.pem

<br/>

**Node2**

    # scp ./ca-cert.pem ubuntu@node2:/home/ubuntu/.docker/ca.pem

    # scp ./node2-cert.pem ubuntu@node2:/home/ubuntu/.docker/cert.pem

    # scp ./node2-key.pem ubuntu@node2:/home/ubuntu/.docker/key.pem

<br/>

**Node3**

    # scp ./ca-cert.pem ubuntu@node3:/home/ubuntu/.docker/ca.pem

    # scp ./node3-cert.pem ubuntu@node3:/home/ubuntu/.docker/cert.pem

    # scp ./node3-key.pem ubuntu@node3:/home/ubuntu/.docker/key.pem

<br/>

**Client**

    # scp ./ca-cert.pem ubuntu@client:/home/ubuntu/.docker/ca.pem

    # scp ./client-cert.pem ubuntu@client:/home/ubuntu/.docker/cert.pem

    # scp ./client-key.pem ubuntu@client:/home/ubuntu/.docker/key.pem

<br/>

### DOCKER DAEMON restarts

**На всех нодах**

    # vim /etc/default/docker

Заменили на (было закомментировано):

    DOCKER_OPTS="-H tcp://0.0.0.0:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem"

<br/>

    # service docker start
    # service docker status

    # ps -elf | grep docker

<br/>

### START NEW CONSUL SERVERS

<br/>

MANAGER1

    # docker -H tcp://manager1:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -d -h consul1 --name consul1 -v /mnt:/data     -p 10.0.1.5:8300:8300     -p 10.0.1.5:8301:8301     -p 10.0.1.5:8301:8301/udp     -p 10.0.1.5:8302:8302     -p 10.0.1.5:8302:8302/udp     -p 10.0.1.5:8400:8400     -p 10.0.1.5:8500:8500     -p 172.17.0.1:53:53/udp     progrium/consul -server -advertise 10.0.1.5 -join 10.0.2.5

<br/>

MANAGER2

    # docker -H tcp://manager2:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -d -h consul2 --name consul2 -v /mnt:/data     -p 10.0.2.5:8300:8300     -p 10.0.2.5:8301:8301     -p 10.0.2.5:8301:8301/udp     -p 10.0.2.5:8302:8302     -p 10.0.2.5:8302:8302/udp     -p 10.0.2.5:8400:8400     -p 10.0.2.5:8500:8500     -p 172.17.0.1:53:53/udp     progrium/consul -server -advertise 10.0.1.5 -join 10.0.1.5

<br/>

MANAGER3

    # docker -H tcp://manager3:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -d -h consul3 --name consul3 -v /mnt:/data     -p 10.0.3.5:8300:8300     -p 10.0.3.5:8301:8301     -p 10.0.3.5:8301:8301/udp     -p 10.0.3.5:8302:8302     -p 10.0.3.5:8302:8302/udp     -p 10.0.3.5:8400:8400     -p 10.0.3.5:8500:8500     -p 172.17.0.1:53:53/udp     progrium/consul -server -advertise 10.0.1.5 -join 10.0.1.5


    # docker -H tcp://manager1:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -h mgr1 --name mgr1 -d -p 3376:2376 -v /home/ubuntu/.docker:/certs:ro swarm manage --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/cert.pem --tlskey=/certs/key.pem --host=0.0.0.0:2376 --replication --advertise 10.0.1.5:2376 consul://10.0.1.5:8500/

<br/>

### START CONSUL CLIENTS

<br/>

NODE1

    # docker -H tcp://node1:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -d -h consul-agt1 --name consul-agt1 \
    -p 8300:8300 \
    -p 8301:8301 -p 8301:8301/udp \
    -p 8302:8302 -p 8302:8302/udp \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:8600/udp \
    progrium/consul -rejoin -advertise 10.0.4.5 -join 10.0.1.5

<br/>

NODE2

    # docker -H tcp://node2:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -d -h consul-agt2 --name consul-agt2 \
    -p 8300:8300 \
    -p 8301:8301 -p 8301:8301/udp \
    -p 8302:8302 -p 8302:8302/udp \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:8600/udp \
    progrium/consul -rejoin -advertise 10.0.5.5 -join 10.0.1.5

<br/>

NODE3

    # docker -H tcp://node3:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -d -h consul-agt3 --name consul-agt3 \
    -p 8300:8300 \
    -p 8301:8301 -p 8301:8301/udp \
    -p 8302:8302 -p 8302:8302/udp \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:8600/udp \
    progrium/consul -rejoin -advertise 10.0.6.5 -join 10.0.1.5

<br/>

### START SWARM MANAGERS

<br/>

MNAGER1

    # docker -H tcp://manager1:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -h mgr1 --name mgr1 -d -p 3376:2376 -v /home/ubuntu/.docker:/certs:ro swarm manage --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/cert.pem --tlskey=/certs/key.pem --host=0.0.0.0:2376 --replication --advertise 10.0.1.5:2376 consul://10.0.1.5:8500/

<br/>

MANAGER2

    # docker -H tcp://manager2:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -h mgr2 --name mgr2 -d -p 3376:2376 -v /home/ubuntu/.docker:/certs:ro swarm manage --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/cert.pem --tlskey=/certs/key.pem --host=0.0.0.0:2376 --replication --advertise 10.0.2.5:2376 consul://10.0.2.5:8500/

<br/>

MANAGER3

    # docker -H tcp://manager3:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run --restart=unless-stopped -h mgr3 --name mgr3 -d -p 3376:2376 -v /home/ubuntu/.docker:/certs:ro swarm manage --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/cert.pem --tlskey=/certs/key.pem --host=0.0.0.0:2376 --replication --advertise 10.0.3.5:2376 consul://10.0.3.5:8500/

<br/>

### START SWARM JOIN CONTAIENRS ON EACH NODE

<br/>

NODE1

    # docker -H tcp://node1:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run -d -h join --name join swarm join --advertise=10.0.4.5:2376 consul://10.0.4.5:8500/

<br/>

NODE2

    # docker -H tcp://node2:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run -d -h join --name join swarm join --advertise=10.0.5.5:2376 consul://10.0.5.5:8500/

<br/>

NODE3

    # docker -H tcp://node3:2376 --tlsverify --tlscacert=/home/ubuntu/.docker/ca.pem --tlscert=/home/ubuntu/.docker/cert.pem --tlskey=/home/ubuntu/.docker/key.pem run -d -h join --name join swarm join --advertise=10.0.6.5:2376 consul://10.0.6.5:8500/

<br/>

**Client**

    $ export DOCKER_HOST=manager1:3376
    $ docker version

    $ export DOCKER_TLS_VERIFY=1
    $ export DOCKER_CERT_PATH=/home/ubuntu/.docker

    $ ls -l .docker/
    (3 сертификата)

    $ docker version
    (получаем данные о клиенте и сервере)

<br/>

### Filtering and Scheduling

    $ docker run -dit ubuntu /bin/bash
    $ docker run -dit ubuntu /bin/bash
    $ docker run -dit ubuntu /bin/bash

    $ docker ps

    $ for i in {1..30}; do /bin/bash -c "docker run -dit ubuntu /bin/bash"; done

<br/>

**Scheduling with RAM Reservations**

    $ docker run -d -m 900m nginx
    $ docker run -d -m 900m nginx

    $ docker info

<br/>

**Affinity Filters**

    $ docker run -d --name c1 nginx
    $ docker run -d --name c2 -e affinity:container==c1 nginx

    $ docker run -d --name c3 -e affinity:container!=c1 nginx
