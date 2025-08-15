---
layout: page
title: Инсталляция Docker в CentOS 7
description: Инсталляция Docker в CentOS 7
keywords: gitops, Инсталляция Docker в CentOS 7
permalink: /tools/containers/docker/setup/centos/7/
---

# Инсталляция Docker в CentOS 7.3

<br/>

Устанавливаю с нуля: 21 ноября 2017  
Добавляю исправления: 29 января 2018

Похоже, что все опять поменялось. Я не успеваю менять инструкции по инсталляции. А все почему? Потому, что владельцы Docker похоже хотят заработать и начинают навязывать платную версию продукта.

<br/>

```
# curl -fsSL https://get.docker.com/ | sh
# Executing docker install script, commit: 11aa13e


    WARNING: ol is now only supported by Docker EE
            Check XXXXXXXXX for information on Docker EE
```

<br/>

### Установка Docker Community Edition

Вот по этой доке.

https://docs.docker.com/engine/installation/linux/docker-ce/centos/#uninstall-old-versions

Требуется пакет container-selinux

    # dnf install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.21-1.el7.noarch.rpm

<br/>

    # dnf install -y yum-utils \
      device-mapper-persistent-data \
      lvm2

<br/>

     # yum-config-manager \
         --add-repo \
         https://download.docker.com/linux/centos/docker-ce.repo

<br/>

    # yum-config-manager --enable docker-ce-edge

    # dnf install -y docker-ce

<br/>

    # docker -v
    Docker version 18.01.0-ce, build 03596f5

<br/>

    # systemctl start docker.service

<br/>

    # systemctl status docker.service


    # systemctl enable docker.service

<br/>

    # groupadd docker

<br/>

    # usermod -aG docker your_username

<br/>

    Log out and log back in.

<br/>

    $ docker run hello-world


    Hello from Docker!
    This message shows that your installation appears to be working correctly.
    ****
