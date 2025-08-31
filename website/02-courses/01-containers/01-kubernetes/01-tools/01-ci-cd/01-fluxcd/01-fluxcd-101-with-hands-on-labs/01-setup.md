---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, fluxcd-101-with-hands-on-labs, Flux Overview
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/setup/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

**Rep'ы автора:**

```
https://github.com/sid-demo?tab=repositories
https://github.com/sidd-harth/block-buster
https://github.com/sidd-harth-2
```

<br/>

К себе нужно форкнуть:

https://github.com/sidd-harth/bb-app-source

Остальные могут понадобиться только для debug.

<br/>

### Подготовка minikube для запуска примеров

<br/>

```
$ LATEST_KUBERNETES_VERSION=v1.27.1
```

<br/>

```
$ export \
    PROFILE=${USER}-minikube \
    CPUS=4 \
    MEMORY=8G \
    HDD=20G \
    DRIVER=docker \
    KUBERNETES_VERSION=${LATEST_KUBERNETES_VERSION}
```

<br/>

### [Поднимаю Minikube](//docs.k8s.ru/tools/containers/kubernetes/minikube/setup/)

### [Устанавливаю FluxCD](//docs.k8s.ru/tools/containers/kubernetes/utils/ci-cd/fluxcd/setup/)

<br/>

```
$ flux --version
flux version 2.0.0-rc.1
```

<br/>

### Создание репо для хранения манифестов

<br/>

```
$ export GITHUB_USER=wildmakaka
$ export REPOSITORY_NAME=block-buster
```

<br/>

```
$ flux bootstrap github \
  --owner=${GITHUB_USER} \
  --repository=${REPOSITORY_NAME} \
  --branch=main \
  --path=flux-clusters/dev-cluster \
  --personal \
  --private=false
```

<br/>

```
$ mkdir -p ~/projects/dev/fluxcd
$ cd ~/projects/dev/fluxcd
```

<br/>

```
$ git clone git@github.com:wildmakaka/block-buster.git
$ git clone git@github.com:wildmakaka/bb-app-source.git
```
