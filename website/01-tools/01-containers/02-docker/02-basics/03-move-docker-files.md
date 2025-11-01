---
layout: page
title: Переместить файлы Docker в другой каталог
description: Переместить файлы Docker в другой каталог
keywords: devops, docker, Переместить файлы Docker в другой каталог
permalink: /devops/containers/docker/basics/move-docker-files/
---

# Переместить файлы Docker в другой каталог

Разожрался докер, пожрал все ресурсы, да еще и на системном разделе

    # du -hx --max-depth=1 /var/lib/docker/ | sort -h
    4.0K	/var/lib/docker/tmp
    8.0K	/var/lib/docker/trust
    132K	/var/lib/docker/execdriver
    776K	/var/lib/docker/volumes
    1.5M	/var/lib/docker/graph
    23M	/var/lib/docker/init
    37M	/var/lib/docker/containers
    3.1G	/var/lib/docker/vfs
    12G	/var/lib/docker/aufs
    15G	/var/lib/docker/

<br/>

### Вариант который использую сейчас

    # service docker stop

<br/>

    # mv /var/lib/docker /mnt/dsk2/docker

<br/>

    # vi /etc/default/docker

Дописываем

    DOCKER_OPTS="-g /mnt/dsk1/docker"

<br/>

    # service docker start

<br/><br/>

Если не заработает, есть еще 1 конфиг файл.  
Может он заработает /etc/default/docker.io

<br/>

### И еще 1 вариант - задать явно, какой файл с конфигом использовать

    # vi /lib/systemd/system/docker.service

<br/>

    ...
    [Service]
    ExecStart=/usr/bin/docker -d -H fd:// $DOCKER_OPTS
    ...
    EnvironmentFile=-/etc/default/docker
    ...

<br/>

    # ps auxwww | grep docker
    root     23246  0.1  0.0 258492 13032 ?        Ssl  11:51   0:00 /usr/bin/docker -d -g /mnt/dsk1/docker
    root     23450  0.0  0.0  17156   936 pts/14   S+   11:55   0:00 grep --color=auto docker

<br/>

Если используется systemd:  
http://stackoverflow.com/questions/30127580/docker-opts-in-etc-default-docker-ignored
