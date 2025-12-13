---
layout: page
title: Получить доступ к сервису HTTP, запущенному в бесплатном облаке google
description: Получить доступ к сервису HTTP, запущенному в бесплатном облаке google
keywords: gitops, containers, kubernetes, setup, google cloud shell, access, ngrok
permalink: /tools/clouds/google/google-cloud-shell/get-access-ngrok/
---

# Получить доступ к сервису HTTP, запущенному в бесплатном облаке google

В веб консоли есть возможность открыть порт, но только для себя. Т.е. удаленные клиенты не смогут подключиться.

Вверху preview on port 8080

<br/>

### Получить доступ к сервису HTTP, запущенному в бесплатном облаке google с помощью ngrok

<br/>

**Делаю:**  
2025.12.13

<br/>

Если нужно для kubernetes, см. [сюда](//docs.k8s.ru//docs.k8s.ru/tools/containers/kubernetes/minikube/ngrok-operator/).

<br/>

Нужно зарегаться  
https://ngrok.com/download

<br/>

```
 $ curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok
```

<br/>

```
// https://dashboard.ngrok.com/get-started/your-authtoken
$ ngrok authtoken <YOUR_AUTH_TOKEN>
```

<br/>

```
$ ngrok http 8080
```
