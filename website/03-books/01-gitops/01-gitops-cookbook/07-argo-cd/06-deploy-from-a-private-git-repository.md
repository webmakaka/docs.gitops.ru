---
layout: page
title: GitOps Cookbook - Argo CD - Deploy from a Private Git Repository
description: С помощью Argo CD развернуть приложение из приватного репозитория
keywords: books, gitops, argo-cd, Deploy from a Private Git Repository
permalink: /books/gitops/gitops-cookbook/argo-cd/deploy-from-a-private-git-repository/
---

<br/>

# [Book] [OK!] 7.6 Deploy from a Private Git Repository

<br/>

**Задача:**  
С помощью Argo CD развернуть приложение из приватного репозитория

<br/>

**Делаю:**  
2025.12.04

<br/>

1. Создаю private git repository https://github.com/wildmakaka/gitops-cookbook-sc-private.git

2. Добавляю в него содержимое https://github.com/gitops-cookbook/gitops-cookbook-sc.git

<br/>

```
$ argocd repo add git@github.com:wildmakaka/gitops-cookbook-sc-private.git \
  --ssh-private-key-path ~/.ssh/wildmakaka
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bgd-app
  namespace: argocd
spec:
  destination:
    namespace: bgd
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: git@github.com:wildmakaka/gitops-cookbook-sc-private.git
    path: ch07/bgd
    targetRevision: main
EOF
```

<br/>

```
$ argocd app list
```

<br/>

```
$ argocd app sync bgd-app
```

<br/>

```
$ kubectl patch svc bgd -n bgd -p '{"spec": {"type": "NodePort"}}'
```

<br/>

```
$ kubectl get services -n bgd
NAME   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
bgd    NodePort   10.99.218.85   <none>        8080:31443/TCP   26s
```

<br/>

```
// [OK!]
http://192.168.58.2:31443
```

<br/>

```
$ argocd app delete bgd-app
```
