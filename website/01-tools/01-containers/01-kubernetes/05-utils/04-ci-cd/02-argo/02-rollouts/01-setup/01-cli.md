---
layout: page
title: Инсталляция CLI Argo Rollouts в ubuntu 22.04
description: Инсталляция CLI Argo Rollouts в ubuntu 22.04
keywords: devops, containers, kubernetes, argo, rollouts, setup, minikube
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/rollouts/setup/cli/
---

# Инсталляция CLI Argo Rollouts в ubuntu 22.04

<br/>

Делаю:  
2024.12.21

<br/>

```
$ cd ~/tmp
$ curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
$ chmod +x ./kubectl-argo-rollouts-linux-amd64
$ sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

<br/>

```
$ kubectl argo rollouts version
kubectl-argo-rollouts: v1.7.2+59e5bd3
  BuildDate: 2024-08-13T18:26:20Z
  GitCommit: 59e5bd385c031600f86075beb9d77620f8d7915e
  GitTreeState: clean
  GoVersion: go1.21.13
  Compiler: gc
  Platform: linux/amd64
```
