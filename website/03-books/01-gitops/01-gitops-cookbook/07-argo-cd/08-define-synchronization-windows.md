---
layout: page
title: GitOps Cookbook - Argo CD - Define Synchronization Windows
description: С помощью Argo CD разрешать или запрещать синхронизацию в зависимости от времени
keywords: books, gitops, argo-cd, Define Synchronization Windows
permalink: /books/gitops/gitops-cookbook/argo-cd/define-synchronization-windows/
---

<br/>

# [Book] [OK!] 7.8 Define Synchronization Windows

<br/>

**Задача:**  
С помощью Argo CD разрешать или запрещать синхронизацию в зависимости от времени

<br/>

**Делаю:**  
2025.12.04

<br/>

Разрешать и запрещать синхронизацию в зависимости от времени.

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: default
spec:
  syncWindows:
  - kind: allow
    schedule: '0 22 * * *'
    duration: 1h
    applications:
    - '*-prod'
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: default
  namespace: argocd
spec:
  syncWindows:
  - kind: deny
    schedule: '0 22 * * *'
    duration: 1h
    manualSync: true
    namespaces:
    - bgd
  - kind: allow
    schedule: '0 23 * * *'
    duration: 1h
    clusters:
    - prod-cluster
EOF
```

<br/>

```
$ argocd proj windows list default
ID  STATUS    KIND   SCHEDULE    DURATION  APPLICATIONS  NAMESPACES  CLUSTERS      MANUALSYNC  TIMEZONE
0   Inactive  deny   0 22 * * *  1h        -             bgd         -             Enabled
1   Inactive  allow  0 23 * * *  1h        -             -           prod-cluster  Disabled
```
