---
layout: page
title: Инсталляция и Upgrade Docker в Astra Linux 1.8
description: Инсталляция и Upgrade Docker в Astra Linux 1.8
keywords: gitops, docker, docker-compose, инсталляция, linux, astra, bash скрипт
permalink: /tools/containers/docker/setup/astra/
---

# Инсталляция и Upgrade Docker в Astra Linux 1.8

<br/>

Делаю:  
2025.03.11

<br/>

### Инсталляция Docker

<br/>

```
$ cat /etc/os-release
PRETTY_NAME="Astra Linux"
NAME="Astra Linux"
ID=astra
ID_LIKE=debian
ANSI_COLOR="1;31"
HOME_URL="https://astralinux.ru"
SUPPORT_URL="https://astralinux.ru/support"
LOGO=astra
VERSION_ID=1.8_x86-64
VERSION_CODENAME=1.8_x86-64
```

<br/>

```
$ sudo vi /etc/apt/sources.list
```

<br/>

```
# Основной репозиторий, включающий актуальное оперативное или срочное обновление
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/main-repository/     1.8_x86-64 main contrib non-free non-free-firmware
# Расширенный репозиторий, соответствующий актуальному оперативному обновлению
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/extended-repository/ 1.8_x86-64 main contrib non-free non-free-firmware
```

<br/>

```
$ sudo apt update
$ sudo apt install docker.io -y
```

<br/>

```
$ sudo usermod -aG docker $USER
```

<br/>

```
$ docker -v
Docker version 25.0.5.astra2, build
```

<br/>

### Install Docker-Compose

<br/>

```bash
$ LATEST_VERSION=$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

// v2.33.1
$ echo $LATEST_VERSION

$ sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

$ sudo chmod +x /usr/local/bin/docker-compose
```

<br/>

```bash
$ docker-compose --version
Docker Compose version v2.33.1
```
