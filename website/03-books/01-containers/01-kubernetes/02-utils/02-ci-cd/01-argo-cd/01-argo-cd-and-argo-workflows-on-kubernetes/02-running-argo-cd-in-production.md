---
layout: page
title: Argo CD and Argo Workflows on Kubernetes
description: Argo CD and Argo Workflows on Kubernetes
keywords: books, ci-cd, argo cd
permalink: /books/containers/kubernetes/utils/ci-cd/argocd/argocd-up-and-running/running-argo-cd-in-production/
---

# [Book][Md Nahidul Kibria] Argo CD and Argo Workflows on Kubernetes: GitOps, workflow automation, and progressive delivery with Argo Rollouts [ENG, 2025]

<br/>

### Chapter 3: Running Argo CD in Production

<br/>

Делаю:  
2025.03.09

<br/>

### Core installation

<br/>

```
// $ minikube --profile argocd-cluster stop && minikube --profile argocd-cluster delete
$ minikube start --nodes=2 --memory=4096 --cpus=2 --kubernetes-version=1.23.1 --driver=docker --profile argocd-cluster
```

<br/>

```
$ kubectl get nodes
NAME                 STATUS   ROLES                  AGE   VERSION
argocd-cluster       Ready    control-plane,master   42s   v1.23.1
argocd-cluster-m02   Ready    <none>                 18s   v1.23.1
```

<br/>

```
$ kubectl create namespace argocd
```

<br/>

```
// Нужно скачать, иначе ошибка
// $ kubectl apply -k https://github.com/argoproj/argo-cd/tree/master/manifests/crds?ref=stable
$ cd Argo-CD-and-Argo-Workflows-on-Kubernetes/resources/argocd/
$ kubectl apply -k crds
```

<br/>

```
$ cd Argo-CD-and-Argo-Workflows-on-Kubernetes/resources/argocd/high-availability
$ kubectl apply -f namespace-install.yaml -n argocd
```

<br/>

```
// Не хватило ресурсов
$ kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          6m13s
argocd-applicationset-controller-8668c86456-vfwtr   1/1     Running   0          6m13s
argocd-dex-server-57cc95c9c4-ncq8t                  1/1     Running   0          6m13s
argocd-notifications-controller-67fcbfc8cf-mc4xl    1/1     Running   0          6m13s
argocd-redis-ha-haproxy-755db98494-dc6t6            0/1     Pending   0          6m13s
argocd-redis-ha-haproxy-755db98494-n4r4n            1/1     Running   0          6m13s
argocd-redis-ha-haproxy-755db98494-swtjb            1/1     Running   0          6m13s
argocd-redis-ha-server-0                            3/3     Running   0          6m13s
argocd-redis-ha-server-1                            3/3     Running   0          4m43s
argocd-redis-ha-server-2                            0/3     Pending   0          3m42s
argocd-repo-server-5fc49df487-54v8t                 1/1     Running   0          6m13s
argocd-repo-server-5fc49df487-b4wgb                 1/1     Running   0          6m13s
argocd-server-59596dfcd9-vm8qg                      1/1     Running   0          6m13s
argocd-server-59596dfcd9-xf8j5                      1/1     Running   0          6m13s
```

<br/>

Чего-то ерунда какая-то супер скучная.
