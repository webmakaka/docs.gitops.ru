---
layout: page
title: Ultimate Argo Bootcamp - ArgoCD
description: Ultimate Argo Bootcamp - ArgoCD
keywords: courses, gitops, argo, Ultimate Argo Bootcamp, ArgoCD
permalink: /courses/gitops/tools/ci-cd/argo/ultimate-argo-bootcamp-by-school-of-devops/argocd/
---

# [School Of DevOps] Ultimate Argo Bootcamp: ArgoCD

<br/>

Делаю:  
2026.01.22

<br/>

```
$ kubectl create ns staging
$ kubectl create ns prod
```

<br/>

ARGOCD -> Settings -> Projects -> New Project

```
Project Name: instavote
Description: Example Voting App
```

<br/>

DESTINATION:

```
Server: https://kubernetes.default.svc
Name: in-cluster
Namespace: staging
```

```
Server: https://kubernetes.default.svc
Name: in-cluster
Namespace: prod
```

<br/>

GITHUB -> FORK -> https://github.com/devops-0006/argo-labs

<br/>

Settings -> Repositories + CONNECT REPO

```
Choose your connection method: VIA HTTP/HTTPS
Type: git

Project: instavote
Repository URL: https://github.com/wildmakaka/argo-labs
```

```
Connect
```

<br/>

Applications -> New App

```
Application Name: vote-staging
Project Name: instavote
Sync Policy: Automatic

+ Enable Auto-Sync
+ Prune Resources
+ Self Heal
```

<br/>

```
SOURCE

Repository URL: https://github.com/wildmakaka/argo-labs
Revision: main
Path: staging
```

```
DESTINATION

Cluster URL: https://kubernetes.default.svc
Namespace: staging
```

```
CREATE
```

<br/>

```
$ kubectl get pods -n staging
NAME                   READY   STATUS    RESTARTS   AGE
vote-c74765f9c-n7mpr   1/1     Running   0          71s
vote-c74765f9c-w8s2w   1/1     Running   0          71s
vote-c74765f9c-zpw4r   1/1     Running   0          71s
vote-c74765f9c-zvj5x   1/1     Running   0          71s
```

<br/>

```
$ kubectl get applications -A
NAMESPACE   NAME           SYNC STATUS   HEALTH STATUS
argocd      vote-staging   Synced        Healthy
```

<br/>

### 07. Configuring GitOps Workflow with Branching Models and Pull Requests

<br/>

Деплоим на production.

<br/>

Создаю branch: release

<br/>

Настроили обязательный merge-request для branch release

GitHub -> argo-labs -> Settings -> Branches -> Add branch ruleset

<br/>

```
Ruleset Name: Prod Deployment
Enforcement status: Active
```

```
Target branches

Add target -> Include by pattern -> Branch naming pattern -> release
```

```
Rules -> + Require a pull request before merging
```

```
Create
```

<br/>

### 08. Defining ArgoCD Applications Spec for Prod Sync with YAML

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vote-prod
  namespace: argocd
spec:
  destination:
    namespace: prod
    server: https://kubernetes.default.svc
  project: instavote
  source:
    path: prod
    repoURL: https://github.com/wildmakaka/argo-labs
    targetRevision: release
  syncPolicy:
    automated:
      enabled: true
      prune: true
      selfHeal: true
EOF
```

<br/>

```
$ kubectl get applications -A
NAMESPACE   NAME           SYNC STATUS   HEALTH STATUS
argocd      vote-prod      Synced        Healthy
argocd      vote-staging   Synced        Healthy
```

<br/>

```
$ kubectl get svc -n staging
NAME           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
vote           NodePort   10.96.107.255   <none>        80:30000/TCP   153m
vote-preview   NodePort   10.96.179.159   <none>        80:30100/TCP   153m
```

<br/>

```
$ kubectl get svc -n prod
NAME           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
vote           NodePort   10.96.226.145   <none>        80:30200/TCP   4m17s
vote-preview   NodePort   10.96.120.76    <none>        80:30300/TCP   4m17s
```

<br/>

```
$ kubectl argo rollouts dashboard -p 3100
```

<br/>

http://localhost:3100/rollouts/rollout/prod/vote

<br/>

```
$ kubectl port-forward svc/vote 30200:80
$ kubectl port-forward svc/vote-preview 30300:80
```

<br/>

```
http://localhost:30200/
http://localhost:30300/
```
