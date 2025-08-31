---
layout: page
title: 02. Запуск приложения в MiniKube с помощью Helm
description: 02. Запуск приложения в MiniKube с помощью Helm
keywords: devops, ci-cd, gitlab, kubernetes, docker, run app in minikube with helm
permalink: /samples/ci-cd/gitlab/kubernetes/run-app-in-minikube/
---

# 02. Запуск приложения в MiniKube с помощью Helm

<br/>

### Docker

```
$ docker -v
Docker version 20.10.0, build 7287ab3
```

<br/>

### [Minikube installation](//docs.k8s.ru/tools/containers/kubernetes/minikube/setup/)

Последний раз делалось на:

```
$ minikube version
minikube version: v1.16.0
```

<br/>

### [Kubectl installation](//docs.k8s.ru/tools/containers/kubernetes/utils/kubectl/)

<br/>

### Run minikube

**Здесь используется драйвер driver virtualbox**

Если использовать docker или kvm, можно посмотреть [здесь](//docs.k8s.ru/tools/containers/kubernetes/minikube/setup/remote-connection-docker/)

<br/>

```
$ {
    minikube --profile devops-app config set memory 8192
    minikube --profile devops-app config set cpus 4

    minikube --profile devops-app config set driver virtualbox
    // minikube --profile devops-app config set driver docker

    minikube --profile devops-app config set kubernetes-version v1.20.2
    minikube start --profile devops-app
}
```

<br/>

```
// Enable ingress
$ minikube addons --profile devops-app enable ingress
```

<br/>

```
$ minikube --profile devops-app ip
192.168.99.100
```

<br/>

```
$ sudo vi /etc/hosts
```

<br/>

```
#---------------------------------------------------------------------
# Minikube
#---------------------------------------------------------------------
192.168.99.100 frontend.minikube.local
192.168.99.100 backend.minikube.local
```

<br/>

### Helm installation

<br/>

    $ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

    $ helm version --short
    v3.5.2+g167aac7

<br/>

### Подготовка проекта

    $ mkdir ~/projects/dev/devops/intensive && cd ~/projects/dev/devops/intensive

    $ git clone https://github.com/webmakaka/Packaging-Applications-with-Helm-for-Kubernetes .

    $ cd apps/v1/chart/guestbook/charts/

<br/>

    // Запуск текстового редактора vscode
    $ code .

<br/>

```
webmakaka/frontend:2.0 меняю на webmakaka/devops-frontend:0.0.10
webmakaka/backend:2.0 меняю на webmakaka/devops-backend:0.0.10
```

<br/>

    $ cd .../projects/dev/devops/intensive/apps/v1/chart

    $ helm install myguestbook guestbook

<br/>

```
$ kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
backend-6689c8d5b8-njwn8    1/1     Running   0          46s
frontend-6dd4d847bd-q257c   1/1     Running   0          46s
mongodb-746c86846c-v4wd6    1/1     Running   0          46s
```

<br/>

frontend.minikube.local

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture02-pic01.png?raw=true)

<br/>

```
$ helm delete myguestbook
```
