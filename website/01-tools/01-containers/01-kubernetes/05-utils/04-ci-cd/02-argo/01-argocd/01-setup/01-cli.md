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
2024.03.25

<br/>

https://github.com/argoproj/argo-cd/releases/latest

<br/>

```
$ cd ~/tmp
$ wget https://github.com/argoproj/argo-cd/releases/download/v2.14.3/argocd-linux-amd64
$ sudo mv argocd-linux-amd64 /usr/local/bin/argocd
$ chmod +x /usr/local/bin/argocd
```
