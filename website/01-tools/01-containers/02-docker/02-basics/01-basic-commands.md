---
layout: page
title: Основные команды Docker
description: Основные команды Docker
keywords: devops, Основные команды Docker
permalink: /tools/containers/docker/basics/basic-commands/
---

# Основные команды Docker

Создать свой репо для контейнеров (1 приватный бесплатно + нет ограничений для публичных контейнеров)  
https://hub.docker.com

---

<br/>

```
$ docker -v

Docker version 1.9.1, build a34a1d5
```

<br/>

```
$ docker version
```

<br/>

```
Client:
    Version:      1.9.1
    API version:  1.21
    Go version:   go1.4.2
    Git commit:   a34a1d5
    Built:        Fri Nov 20 13:12:04 UTC 2015
    OS/Arch:      linux/amd64

Server:
    Version:      1.9.1
    API version:  1.21
    Go version:   go1.4.2
    Git commit:   a34a1d5
    Built:        Fri Nov 20 13:12:04 UTC 2015
    OS/Arch:      linux/amd64
```

<br/>

```
$ docker info
```

<br/>

```
Containers: 3
Images: 87
Server Version: 1.9.1
Storage Driver: aufs
    Root Dir: /mnt/dsk1/docker/aufs
    Backing Filesystem: extfs
    Dirs: 93
    Dirperm1 Supported: true
Execution Driver: native-0.2
Logging Driver: json-file
Kernel Version: 3.19.0-42-generic
Operating System: Ubuntu 14.04.3 LTS
CPUs: 8
Total Memory: 23.54 GiB
Name: workstation
ID: O6JG:4MOF:M526:3PJV:FQHZ:3ERJ:P7KW:U3VN:D6AZ:C46E:SSH3:IADV
Username: marley
Registry: https://index.docker.io/v1/
WARNING: No swap limit support
```

<br/>

```
// поискать в репо что-нибуть
$ docker search centos
```

```
// взять из репо последнюю версию debian
$ docker pull debian
```

```
// взять все версии debian
$ docker pull -a debian
```

```
// получить список скачанных images
$ docker images
$ docker images --tree
$ docker images debian
```

<br/>

### Переименовать image

```
// Переименовываю имидж. Чтобы контейнер на hub.docker.com начинался с моего username
$ docker tag centos6/rais:v01 marley/centos6-for-jekyll:latest
```

```
// Запустить контейнер и отправить 30 пингов до гугла
$ docker run -d ubuntu /bin/bash -c "ping 8.8.8.8 -c 30"
```

```
// Запустить интерактивно контейнер и в контейнере shell
$ docker run -i -t centos:centos6 /bin/bash
```

<br/>

```
-d - Detached mode (зупустится в фоне)
```

<br/>

```
$ docker run -i -t -d debian
```

Задать имя, иначе она будет выбрано самостоятельно

```
$ docker run -i -t -d  --name myDebianServ debian
```

// Контенеры и имиджи хранятся здесь

```
$ cat /var/lib/docker/aufs/diff/<container_id>

$ ls -l /var/lib/docker/containers
$ ls -l /var/lib/docker/containers | wc -l
```

<br/>

```
// показать активные контейнеры
$ docker ps
```

```
// показать все контейнеры в том числе остановленные
$ docker ps -a
```

```
// Последний стартовавший контейнер.
$ docker ps -l
```

```
// Старт стоп

$ docker start <container_id>
$ docker stop <container_id>
$ docker kill <container_id>
$ docker restart <container_id>
```

```
// Сколько жрет ресурсов

$ docker stats <container_id>
$ docker top <container_id> -ef
```

```
// Отключиться от контейнера docker без его остановки:
CTRL + P + Q
```

```
// Подключиться
$ docker attach <container_id>
```

```
// Подключиться еще одной сессией к контейнеру
$ docker exec -it <container_id> bash
```

<br/>

```
$ docker top <container_id>
$ docker inspect <container_id>
$ docker logs <container_id>
```

```
// Показать какие порты локальной машины соответствуют портам контейнера
$ docker port <container_id>
```

Пример

    $ docker port my_container

    1337/tcp -> 0.0.0.0:1337
    3000/tcp -> 0.0.0.0:3000
    8080/tcp -> 0.0.0.0:80
    9000/tcp -> 0.0.0.0:9000

// узнать IP контейнера Docker

    $ docker inspect --format='{{.NetworkSettings.IPAddress}}' containerId

<br/>

### Остановка и удаление

```
// Удалить контейнер
$ docker rm  <container_id>
$ docker rm -f <container_id>
```

```
// Остановить все контейнеры:
$ docker stop $(docker ps -a -q)
```

```
// Удалить все контейнеры:
$ docker rm $(docker ps -a -q)
```

```
// Удалить все остановленные контейнеры:
$ docker rm $(docker ps -qa --no-trunc --filter "status=exited")
```

```
// Удалить все images:
# docker rmi $(docker images -q)
```

```
// Если Error when deleting images - image is referenced in multiple repositories:
# docker rmi -f $(docker images -q)
```

```
// Удалить неиспользуемые образы:
$ docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
```

<br/>

### Удаление всех созданных ресурсов Docker

<br/>

```
$ {
    docker system prune -af
    docker container prune -f
    docker image prune -f
    docker volume prune -f
    docker network prune -f
}
```

<br/>

### Системная информация

```
$ docker system info
```

<br/>

### Посмотреть содержимое

<br/>

```
$ docker inspect mariadb | less
$ docker image history mariadb
```

<br/>

### Получить информацию о слоях image

```
$ docker history <image_name>
$ docker history --no-trunc <image_name>
```

<br/>

Возможно, более наглядно.

https://github.com/CenturyLinkLabs/dockerfile-from-image

Хочу понять каким образом был сделан docker image у автора курса по CoreOS

<br/>

```
$ docker pull rosskukulinski/rethinkdb:2.1.0_beta1
```

<br/>

```
$ docker run -v /var/run/docker.sock:/var/run/docker.sock centurylink/dockerfile-from-image rosskukulinski/rethinkdb:2.1.0_beta1
ADD file:085531d120d9b9b09174b936e2ecac25dda1f3029cfbc24751529c0c24a8e3d0 in /
CMD ["/bin/bash"]
MAINTAINER Stuart P. Bentley <stuart@testtrack4.com>
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 1614552E5765227AEC39EFCFA7E00EF33A8F2399
RUN echo "deb http://download.rethinkdb.com/apt jessie main" > /etc/apt/sources.list.d/rethinkdb.list
RUN apt-get update
RUN apt-get -yqq install build-essential protobuf-compiler python libprotobuf-dev libcurl4-openssl-dev libboost-all-dev libncurses5-dev libjemalloc-dev wget
ADD tarsum+sha256:9fa9e6a402710827733f45452cb37b43a2b8d2949e9800d8937a78377d04e619 in /src/rethinkdb_2.1.0.deb
RUN dpkg -i /src/rethinkdb_2.1.0.deb
RUN apt-get -yqqf install
VOLUME [/data]
WORKDIR /data
CMD ["rethinkdb" "--bind" "all"]
EXPOSE 28015/tcp 29015/tcp 8080/tcp
```
