---
layout: page
title: Инсталляция и Upgrade Docker в Ubuntu 22.04
description: Инсталляция и Upgrade Docker в Ubuntu 22.04
keywords: gitops, docker, docker-compose, инсталляция, linux, ubuntu, bash скрипт
permalink: /tools/containers/docker/setup/ubuntu/
---

# Инсталляция / Upgrade Docker в Ubuntu 22.04

Делаю:  
2025.03.08

<br/>

### Инсталляция Docker

<br/>

```
$ mkdir ~/tmp
$ cd ~/tmp
```

<br/>

```
$ vi install-docker-and-docker-compose.sh
```

<br/>

```bash
#!/bin/bash

### Install Docker

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce


### Install Docker-Compose

LATEST_VERSION=$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

<br/>

```
$ chmod +x ./install-docker-and-docker-compose.sh
$ sudo ./install-docker-and-docker-compose.sh
```

<br/>

```
$ docker -v
Docker version 28.0.1, build 068a01e

$ docker-compose --version
Docker Compose version v2.33.1
```

<br/>

### Предоставить пользователю права для работы с docker

```
// Добавить текущего пользоателя в группу для работы с docker
$ sudo usermod -aG docker ${USER}
```

<br/>

в группе docker должен появиться этот пользователь

```
$ cat /etc/group | grep docker
docker:x:999:marley
```

<br/>

Перелогиниваемся, иначе не будет работать

```
$ logout
```

Лучше даже сделать reboot.

```
$ sudo reboot
```

<br/>

```
// Но можно и
$ newgrp docker
```

<br/>

### (При необходимости!) Изменить каталог по умолчанию для хранения контейнеров и имиджей

Делаю:  
13.08.2022

<br/>

```
$ sudo mkdir -p /etc/systemd/system/docker.service.d
$ sudo vi /etc/systemd/system/docker.service.d/docker-storage.conf
```

<br/>

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --data-root="/mnt/dsk1/docker"
```

<br/>

```
# systemctl daemon-reload
# systemctl restart docker
```

```
# ps auxwww | grep docker
root       14893  0.7  0.4 1382816 77408 ?       Ssl  23:49   0:00 /usr/bin/dockerd -H fd:// --data-root=/mnt/dsk1/docker
root       15005  0.0  0.0   9048   656 pts/8    S+   23:49   0:00 grep --color=auto docker

```

<br/>

### Разрешить работы с определенными registry по HTTP

<br/>

```
**Текст ошибки:**
http: server gave HTTP response to HTTPS client
```

<br/>

```
$ sudo vi /etc/docker/daemon.json
```

<br/>

```
{
    "insecure-registries": ["localhost:5000"]
}
```

<br/>

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

<br/>

### Error response from daemon: Get "https://my-host/v2/": tls: failed to verify certificate: x509: certificate signed by unknown authority

Тоже самое, что и выше.

Но не нужно указывать https:// и /v2/

<br/>

```
$ docker info
***
Insecure Registries:
localhost:5000
127.0.0.0/8
```

<br/>

### Отключить автозапуск контейнеров docker-compose

```
// We can stop specific container by going to the specific directory and then running the following command
$ docker-compose down


// To prevent a specific container from auto starting when a system is powered on
$ docker update --restart=no [container id]
```
