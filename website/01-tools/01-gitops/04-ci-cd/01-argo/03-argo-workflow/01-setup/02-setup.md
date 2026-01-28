---
layout: page
title: Инсталляция Argo WorkFlow
description: Инсталляция Argo WorkFlow
keywords: devops, containers, kubernetes, Argo WorkFlow, setup
permalink: /tools/gitops/ci-cd/argo/argo-workflow/setup/
---

# Инсталляция Argo WorkFlow

<br/>

Делаю:  
2026.01.22

<br/>

https://argo-workflows.readthedocs.io/en/latest/quick-start/

https://github.com/argoproj/argo-workflows/releases/

<br/>

### [CLI Argo WorkFlow](/tools/gitops/ci-cd/argo/argo-workflow/setup/cli/)

<br/>

```
$ ARGO_WORKFLOWS_VERSION="v3.7.8"

$ kubectl create namespace argo
$ kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/quick-start-minimal.yaml"
```

<br/>

```
$ kubectl get pods -n argo
NAME                                   READY   STATUS    RESTARTS   AGE
argo-server-b6db7d4b4-nxbq4            1/1     Running   0          60s
httpbin-58d7595979-5b458               1/1     Running   0          60s
minio-5cb4ff75c9-vqzhd                 1/1     Running   0          60s
workflow-controller-7d4fc9f476-8ls95   1/1     Running   0          60s
```

<br/>

```
$ kubectl get crd | grep workflow
clusterworkflowtemplates.argoproj.io   2026-01-22T01:34:24Z
cronworkflows.argoproj.io              2026-01-22T01:34:24Z
workflowartifactgctasks.argoproj.io    2026-01-22T01:34:24Z
workfloweventbindings.argoproj.io      2026-01-22T01:34:24Z
workflows.argoproj.io                  2026-01-22T01:34:24Z
workflowtaskresults.argoproj.io        2026-01-22T01:34:25Z
workflowtasksets.argoproj.io           2026-01-22T01:34:25Z
workflowtemplates.argoproj.io          2026-01-22T01:34:25Z
```

<br/>

```
$ kubectl -n argo port-forward --address 0.0.0.0 svc/argo-server 2746:2746 > /dev/null
```
