---
layout: page
title: Инсталляция Tekton в ubuntu 22.04
description: Инсталляция Tekton в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, tekton, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/tekton/
---

# Инсталляция Tekton в ubuntu 22.04

<br/>

**Делаю:**  
2025.11.25

<br/>

### Инсталляция Tekton CLI

<br/>

```
$ mkdir ~/tmp
$ cd ~/tmp/
```

<br/>

```
$ vi tekton-setup.sh
```

<br/>

```
#!/bin/bash

export LATEST_VERSION=$(curl --silent "https://api.github.com/repos/tektoncd/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

export LATEST_VERSION_SHORT=$(curl --silent "https://api.github.com/repos/tektoncd/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c 2-)

curl -LO "https://github.com/tektoncd/cli/releases/download/${LATEST_VERSION}/tkn_${LATEST_VERSION_SHORT}_$(uname -s)_$(uname -m).tar.gz"

sudo tar xvzf tkn_${LATEST_VERSION_SHORT}_$(uname -s)_$(uname -m).tar.gz -C /usr/local/bin/ tkn
```

<br/>

```
$ bash tekton-setup.sh
```

```
$ tkn version
Client version: 0.43.0
```

<br/>

### Добавляем Tekton CRD

<br/>

```
$ kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

<br/>

```
$ tkn version
Client version: 0.43.0
Pipeline version: v1.6.0
```

<br/>

```
$ kubectl get pods -n tekton-pipelines
NAME                                         READY   STATUS    RESTARTS   AGE
tekton-events-controller-7bb8d8b8cc-5j7q4    1/1     Running   0          30s
tekton-pipelines-controller-f5b46dd7-rm565   1/1     Running   0          30s
tekton-pipelines-webhook-6659bdfd6d-n8n5v    0/1     Running   0          30s
```

<br/>

```
$ kubectl get pods -n tekton-pipelines-resolvers
NAME                                                 READY   STATUS    RESTARTS   AGE
tekton-pipelines-remote-resolvers-797b749dcc-pt6m6   1/1     Running   0          48s
```

<br/>

```
$ kubectl get crds
NAME                                       CREATED AT
customruns.tekton.dev                      2025-11-24T19:41:18Z
pipelineruns.tekton.dev                    2025-11-24T19:41:18Z
pipelines.tekton.dev                       2025-11-24T19:41:18Z
resolutionrequests.resolution.tekton.dev   2025-11-24T19:41:18Z
stepactions.tekton.dev                     2025-11-24T19:41:18Z
taskruns.tekton.dev                        2025-11-24T19:41:19Z
tasks.tekton.dev                           2025-11-24T19:41:18Z
verificationpolicies.tekton.dev            2025-11-24T19:41:19Z
```

<br/>

### [Дополнительно] Добавление Tekton Dashboard

<br/>

```
$ kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml
```

<br/>

**Подключиться к dashboard**

<br/>

```
$ kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 8080:9097
```

<br/>

```
$ localhost:8080
```

<br/>

### [Дополнительно] Installing Tekton Triggers

<br/>

```
// Install the trigger custom resource definitions (CRDs)
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

// An interceptor is an object that contains the logic necessary to validate and filter webhooks coming from various sources.
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
```

<br/>

```
// Examples
$ kubectl apply -f https://raw.githubusercontent.com/tektoncd/triggers/main/examples/rbac.yaml
```

<br/>

Now that Triggers is installed, you will be able to listen for events from GitHub, but for the webhooks to reach your cluster, you will need to expose a route to the outside world.

<br/>

```
$ kubectl get pods -n tekton-pipelines
NAME                                                READY   STATUS    RESTARTS   AGE
tekton-dashboard-699dcfc5b-fzs6t                    1/1     Running   0          7m13s
tekton-events-controller-7bb8d8b8cc-5j7q4           1/1     Running   0          9m33s
tekton-pipelines-controller-f5b46dd7-rm565          1/1     Running   0          9m33s
tekton-pipelines-webhook-6659bdfd6d-n8n5v           1/1     Running   0          9m33s
tekton-triggers-controller-6489447bd7-9q62v         1/1     Running   0          7m2s
tekton-triggers-core-interceptors-99f845fb7-s6hzn   1/1     Running   0          6m49s
tekton-triggers-webhook-7dcd7b4958-69xcc            1/1     Running   0          7m2s
```

<br/>

```
$ tkn version
Client version: 0.43.0
Pipeline version: v1.6.0
Triggers version: v0.34.0
Dashboard version: v0.63.1
```
