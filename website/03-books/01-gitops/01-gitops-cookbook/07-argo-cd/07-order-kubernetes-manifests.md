---
layout: page
title: GitOps Cookbook - Argo CD - Order Kubernetes Manifests
description: С помощью Argo CD задеплоить приложение из нескольких микросервисов
keywords: books, gitops, argo-cd, Order Kubernetes Manifests
permalink: /books/gitops/gitops-cookbook/argo-cd/order-kubernetes-manifests/
---

<br/>

# [Book] [OK!] 7.7 Order Kubernetes Manifests

<br/>

**Задача:**  
С помощью Argo CD задеплоить приложение из нескольких микросервисов

<br/>

**Делаю:**  
2025.12.04

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: todo-app
  namespace: argocd
spec:
  destination:
    namespace: todo
    server: https://kubernetes.default.svc
  project: default
  source:
    path: ch07/todo
    repoURL: https://github.com/wildmakaka/gitops-cookbook-sc.git
    targetRevision: main
  syncPolicy:
    automated:
      prune: true
      selfHeal: false
    syncOptions:
      - CreateNamespace=true
EOF
```

<br/>

Походу база поднялась, данные в нее пролились. Еще какая-то ерунда запустилась хз для чего.

<br/>

```
$ kubectl get pods -n todo
NAME                           READY   STATUS      RESTARTS   AGE
postgresql-65fbf64479-zqsml    1/1     Running     0          3m18s
todo-gitops-685944c585-zxrhv   1/1     Running     0          2m29s
todo-table-8v9sv               0/1     Completed   0          2m53s
```
