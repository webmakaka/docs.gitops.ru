---
layout: page
title: Argo CD and Argo Workflows on Kubernetes
description: Argo CD and Argo Workflows on Kubernetes
keywords: books, ci-cd, argo cd
permalink: /books/containers/kubernetes/utils/ci-cd/argocd/argocd-up-and-running/understanding-argo-cd/
---

# [Book][Md Nahidul Kibria] Argo CD and Argo Workflows on Kubernetes: GitOps, workflow automation, and progressive delivery with Argo Rollouts [ENG, 2025]

<br/>

### Chapter 2: Understanding Argo CD

<br/>

Делаю:  
2025.03.02

<br/>

```
# Create a new application in Argo CD
# --repo: Source Git repository
# --path: Path within the repository
# --dest-server: Target Kubernetes cluster
# --dest-namespace: Target namespace

# Use the following command to create guestbook app in argocd
$ argocd app create guestbook \
--repo https://github.com/argoproj/argocd-example-apps.git \
--path guestbook \
--dest-server https://kubernetes.default.svc \
--dest-namespace default
```

<br/>

```
$ argocd app list
NAME              CLUSTER                         NAMESPACE  PROJECT  STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                 PATH       TARGET
argocd/guestbook  https://kubernetes.default.svc  default    default  OutOfSync  Missing  Manual      <none>      https://github.com/argoproj/argocd-example-apps.git  guestbook
```

<br/>

```
$ argocd app get guestbook
Name:               argocd/guestbook
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                https://192.168.49.2:31360/applications/guestbook
Source:
- Repo:             https://github.com/argoproj/argocd-example-apps.git
  Target:
  Path:             guestbook
SyncWindow:         Sync Allowed
Sync Policy:        Manual
Sync Status:        OutOfSync from  (4773b9f)
Health Status:      Missing

GROUP  KIND        NAMESPACE  NAME          STATUS     HEALTH   HOOK  MESSAGE
       Service     default    guestbook-ui  OutOfSync  Missing
apps   Deployment  default    guestbook-ui  OutOfSync  Missing
```

<br/>

```
$ argocd app diff guestbook

===== /Service default/guestbook-ui ======
0a1,13
> apiVersion: v1
> kind: Service
> metadata:
>   labels:
>     app.kubernetes.io/instance: guestbook
>   name: guestbook-ui
>   namespace: default
> spec:
>   ports:
>   - port: 80
>     targetPort: 80
>   selector:
>     app: guestbook-ui

===== apps/Deployment default/guestbook-ui ======
0a1,23
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   labels:
>     app.kubernetes.io/instance: guestbook
>   name: guestbook-ui
>   namespace: default
> spec:
>   replicas: 1
>   revisionHistoryLimit: 3
>   selector:
>     matchLabels:
>       app: guestbook-ui
>   template:
>     metadata:
>       labels:
>         app: guestbook-ui
>     spec:
>       containers:
>       - image: gcr.io/heptio-images/ks-guestbook-demo:0.2
>         name: guestbook-ui
>         ports:
>         - containerPort: 80
```

<br/>

```
$ argocd app sync guestbook
```

<br/>

```
$ argocd app get guestbook
```
