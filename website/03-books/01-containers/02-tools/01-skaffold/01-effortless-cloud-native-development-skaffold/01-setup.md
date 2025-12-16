---
layout: page
title: Building CI/CD Systems Using Tekton - Подготовка стенда
description: Building CI/CD Systems Using Tekton - Подготовка стенда
keywords: books, ci-cd, tekton, Подготовка стенда
permalink: /books/containers/kubernetes/tools/skaffold/setup/
---

# Подготовка стенда

<br/>

**Делаю:**  
2025.12.14

<br/>

1. Инсталляция [MiniKube](//docs.k8s.ru/tools/containers/kubernetes/minikube/setup/)

2. Инсталляция [Kubectl](//docs.k8s.ru/tools/containers/kubernetes/utils/kubectl/)

3. Инсталляция [Skaffold](/tools/containers/kubernetes/utils/scaffold/)

<br/>

```
$ sudo apt install -y openjdk-17-jdk
$ sudo apt install -y jq
```

<br/>

### Установить контекст как локальный кластер

```
$ export \
  PROFILE=marley-minikube
```

<br/>

```
$ skaffold config set --kube-context ${PROFILE} local-cluster true
```

<br/>

```
// Оригинальные коды:
$ git clone https://github.com/PacktPublishing/Effortless-Cloud-Native-App-Development-Using-Skaffold
```
