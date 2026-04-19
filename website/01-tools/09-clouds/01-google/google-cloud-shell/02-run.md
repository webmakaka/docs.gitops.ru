---
layout: page
title: Беслпатное облако Google инсталляция и подключение
description: Беслпатное облако Google инсталляция и подключение
keywords: gitops, containers, kubernetes, setup, google cloud shell
permalink: /tools/clouds/google/google-cloud-shell/run/
---

# Беслпатное облако Google инсталляция и подключение

<br/>

### Подключение к google-cloud-sdk

<br/>

**Делаю:**  
2026.04.10

```shell
// 1 раз нужно залогиниться
$ gcloud auth login

// Далее достаточно просто выполнять для подключения
$ gcloud cloud-shell ssh

// В debug режиме
// $ gcloud cloud-shell ssh --ssh-flag="-vvv"
```

<br/>

**P.S.**

1. Виртуальную машинку можно рестартовать и откатить в начальное состояние в UI

2. При необходимости, удалить google ключи из каталога ~/.ssh/

<br/>

### Полезные команды

<br/>

**Скачать telegram:**

```shell
// В google cloudshell
$ curl -L -o telegram.tar.xz "https://telegram.org/dl/desktop/linux"
```

<br/>

```shell
// На localhost
$ gcloud cloud-shell scp cloudshell:/home/<USER_NAME>/telegram.tar.xz localhost:/home/marley/tmp
```

<br/>

**Скачать youtube playlist**

<br/>

[Скачать playlist с youtube в командной строке ubuntu linux (yt-dlp)](//docs.sysadm.ru/desktop/linux/ubuntu/download-youtube-playlist/)

<br/>

```shell
// В google cloudshell
$ sudo apt install -y p7zip-full
$ 7z a -v999m myPlaylist.zip ./myPlaylist
```

<br/>

```shell
// На localhost
$ gcloud cloud-shell scp cloudshell:/home/a3333333/Downloads/myPlaylist.zip.001 localhost:/home/marley/tmp
```
