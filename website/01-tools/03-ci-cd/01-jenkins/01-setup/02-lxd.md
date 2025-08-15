---
layout: page
title: Инсталляция Jenkins в LXD
description: Инсталляция Jenkins в LXD
keywords: ci-cd, Инсталляция Jenkins в LXD
permalink: /tools/ci-cd/jenkins/lxd/setup/
---

# Инсталляция Jenkins в LXD

Делаю:  
2025.08.15

<br/>

### Инсталляция в linux

https://www.jenkins.io/doc/book/installing/linux/#debianubuntu


<br/>

```
$ lxc launch ubuntu:24.04 jenkins-lxc
$ lxc exec jenkins-lxc -- bash
```

<br/>

### Установка Jenkins внутри контейнера

```
$ apt update && apt upgrade -y
$ apt install openjdk-17-jre -y
```

<br/>

```
$ curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

$ echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

$ apt update
```

<br/>

```
$ apt install jenkins -y
```


<br/>


```
$ systemctl enable --now jenkins
$ systemctl status jenkins 
```

<br/>


### 5. Настройка доступа к Jenkins


```
$ lxc list

// Проброс порта 8080 на хост 
$ lxc config device add jenkins-lxc jenkins-port proxy listen=tcp:0.0.0.0:8080 connect=tcp:127.0.0.1:8080
```

<br/>

```
// Теперь Jenkins доступен по:
http://<IP_хоста>:8080
```

<br/>

```
$ lxc exec jenkins-lxc -- bash
# cat /var/lib/jenkins/secrets/initialAdminPassword
```

<br/>

### 6. Дополнительные настройки (опционально)


```
// 6.1. Автоматический запуск контейнера при загрузке
$ lxc config set jenkins-lxc boot.autostart true
```

<br/>

```
// 6.2. Создание снапшота (резервной копии)
$ lxc snapshot jenkins-lxc initial-setup
```

