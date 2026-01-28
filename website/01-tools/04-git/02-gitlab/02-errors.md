---
layout: page
title: GitLab - error during connect Post http://docker:2375/v1.24/auth dial tcp lookup docker on 10.0.2.3:53 server misbehaving
description: GitLab - error during connect Post http://docker:2375/v1.24/auth dial tcp lookup docker on 10.0.2.3:53 server misbehaving
keywords: devops, gitops, cvs, gitlab, error during connect, server misbehaving
permalink: /tools/git/gitlab/errors/
---

# [GitLab Error] error during connect: Post http://docker:2375/v1.24/auth: dial tcp: lookup docker on 10.0.2.3:53: server misbehaving

<br/>

Делаю:  
03.02.2021

<br/>

Записываю, т.к. потерял кучу времени на решение, как мне кажется, неочевидной ошибки в логах упавшей job в gitlab, и найти сразу решение не удалось.

<br/>

**Как я исправлял:**

<br/>

**Добавил:**

<br/>

```
$ vi .gitlab-ci.yml
```

<br/>

```
image: docker:stable

variables:
  DOCKER_TLS_CERTDIR: ''
  DOCKER_HOST: tcp://192.168.0.5:2375
  DOCKER_DRIVER: overlay2

services:
  - docker:stable-dind
```

<br/>

В общем, нужно, чтобы можно было подключиться к сервису docker по tcp откда-то из gitlab.

Но, чтобы это сделать, нужно еще и сервис настроить, чтобы он слушал запросы.

<br/>

Хз насколько это правильно с т.з. безопасности.

<br/>

```
$ sudo mkdir -p /etc/systemd/system/docker.service.d/

$ sudo vi /etc/systemd/system/docker.service.d/docker.conf

```

<br/>

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```

<br/>

    $ sudo systemctl daemon-reload
    $ sudo systemctl restart docker.service
    $ systemctl status docker.service

<br/>

```
CGroup: /system.slice/docker.service
        └─780 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```

<br/>

Должен показывать, что теперь слушает порт 2375.

<br/>

**Подсмотрено здесь:**

https://stackoverflow.com/questions/26561963/how-to-detect-a-docker-daemon-port
