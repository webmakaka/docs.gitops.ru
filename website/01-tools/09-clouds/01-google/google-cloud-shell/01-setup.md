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
2026.04.10

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
Google Cloud SDK 562.0.0
bq 2.1.30
bundled-python3-unix 3.13.10
core 2026.03.23
gcloud-crc32c 1.0.0
gsutil 5.36
```
