---
layout: page
title: Инсталляция CLI Argo Rollouts в ubuntu 22.04
description: Инсталляция CLI Argo Rollouts в ubuntu 22.04
keywords: devops, containers, kubernetes, argo, rollouts, setup, minikube
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argo-rollouts/setup/cli/
---

# Инсталляция CLI Argo Rollouts в ubuntu 22.04

<br/>

Делаю:  
2026.01.19

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
kubectl-argo-rollouts: v1.8.3+49fa151
  BuildDate: 2025-06-04T22:15:54Z
  GitCommit: 49fa1516cf71672b69e265267da4e1d16e1fe114
  GitTreeState: clean
  GoVersion: go1.23.9
  Compiler: gc
  Platform: linux/amd64
```
