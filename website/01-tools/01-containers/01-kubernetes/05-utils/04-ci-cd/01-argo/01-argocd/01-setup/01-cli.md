---
layout: page
title: Инсталляция ArgoCD CLI
description: Инсталляция ArgoCD CLI
keywords: tools, containers, kubernetes, ci-cd, argocd, setup, cli, minikube
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argocd/setup/cli/
---

# Инсталляция ArgoCD CLI

<br/>

Делаю:  
2025.12.05

<br/>

https://github.com/argoproj/argo-cd/releases/latest

<br/>

```
$ cd ~/tmp
$ wget https://github.com/argoproj/argo-cd/releases/download/v3.2.1/argocd-linux-amd64
$ sudo mv argocd-linux-amd64 /usr/local/bin/argocd
$ chmod +x /usr/local/bin/argocd
```

<br/>

```
$ argocd version
argocd: v3.2.1+8c4ab63
```
