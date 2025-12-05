---
layout: page
title: Инсталляция Argo Rollouts в kind
description: Инсталляция Argo Rollouts в kind
keywords: devops, containers, kubernetes, argo, rollouts, setup, minikube
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/rollouts/setup/
---

# Инсталляция Argo Rollouts в kind

<br/>

Делаю:  
2024.12.21

<br/>

```
$ kubectl create namespace argo-rollouts
$ kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

<br/>

```
$ kubectl api-resources | grep -i argo
```

<br/>

```
$ kubectl get pods -n argo-rollouts
NAME                             READY   STATUS    RESTARTS   AGE
argo-rollouts-6f4f78ffd8-n6425   1/1     Running   0          65s
```

<br/>

### Argo plugin for kubectl

https://kubernetes-tutorial.schoolofdevops.com/argo_rollout_blue_green/

<br/>

```
cd ~

curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64

chmod +x ./kubectl-argo-rollouts-linux-amd64

sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

<br/>

```
kubectl argo rollouts version
```
