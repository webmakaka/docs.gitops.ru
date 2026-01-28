---
layout: page
title: Инсталляция ArgoCD CLI
description: Инсталляция ArgoCD CLI
keywords: tools, gitops, kubernetes, ci-cd, argocd, setup, cli, minikube
permalink: /tools/gitops/ci-cd/argo/argo-cd/setup/minikube/cli/
---

# Инсталляция ArgoCD CLI

<br/>

Делаю:  
2025.12.09

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

<br/>

```
// Посмотреть текущие контексты и серверы
argocd context
```

<br/>

```
// Очистить кеш конфигурации
rm -rf ~/.config/argocd/
```
