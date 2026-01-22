---
layout: page
title: Инсталляция Argo Events
description: Инсталляция Argo Events
keywords: devops, containers, kubernetes, Argo Events, setup
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argo-events/setup/
---

# Инсталляция Argo Events

<br/>

Делаю:  
2026.01.22

<br/>

```
$ kubectl create namespace argo-events
```

<br/>

```
$ kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml

# Install with a validating admission controller
$ kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml

$ kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
```

<br/>

### Create RBAC Policies

```
$ kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/rbac/sensor-rbac.yaml

$ kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/rbac/workflow-rbac.yaml
```

<br/>

```
$ kubectl get pods -n argo-events
NAME                                  READY   STATUS    RESTARTS   AGE
controller-manager-59884fd695-qgnxk   1/1     Running   0          7m34s
eventbus-default-stan-0               2/2     Running   0          6m58s
eventbus-default-stan-1               2/2     Running   0          6m47s
eventbus-default-stan-2               2/2     Running   0          6m46s
events-webhook-588ccdfcb5-bcpg9       1/1     Running   0          7m22s
```
