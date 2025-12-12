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
2025.12.13

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
