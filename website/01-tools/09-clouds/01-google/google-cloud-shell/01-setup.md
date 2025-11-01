---
layout: page
title: Беслпатное облако Google инсталляция и подключение
description: Беслпатное облако Google инсталляция и подключение
keywords: gitops, containers, kubernetes, setup, google cloud shell
permalink: /tools/clouds/google/google-cloud-shell/setup/
---

# Беслпатное облако Google инсталляция и подключение

<br/>

### Инсталляция google-cloud-sdk

<br/>

**Делаю:**  
2025.10.21

<br/>

```
$ cd ~/tmp

$ curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz

$ tar -zxvf google-cloud-cli-linux-x86_64.tar.gz

$ cd google-cloud-sdk/

$ ./install.sh

$ source ~/.bashrc
```

<br/>

```
$ gcloud --version
Google Cloud SDK 543.0.0
bq 2.1.24
bundled-python3-unix 3.12.9
core 2025.10.10
gcloud-crc32c 1.0.0
gsutil 5.35
```

<br/>

### Подключение к google-cloud-sdk

<br/>

**Делаю:**  
2025.10.21

```
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
