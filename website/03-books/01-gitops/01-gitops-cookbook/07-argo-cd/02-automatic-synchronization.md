---
layout: page
title: GitOps Cookbook - Argo CD - Automatic Synchronization
description: С помощью Argo CD автоматически обновлять ресурсы при изменениях
keywords: books, gitops, argo-cd, Automatic Synchronization
permalink: /books/gitops/gitops-cookbook/argo-cd/automatic-synchronization/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 07. Argo CD: 7.2 Automatic Synchronization

<br/>

Делаю:  
2025.12.04

<br/>

**Задача:**
С помощью Argo CD автоматически обновлять ресурсы при изменениях

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bgd-app
  namespace: argocd
spec:
  destination:
    namespace: bgd
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/wildmakaka/gitops-cookbook-sc.git
    path: ch07/bgd
    targetRevision: main
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

<br/>

```
$ kubectl patch svc bgd -n bgd -p '{"spec": {"type": "NodePort"}}'
```

<br/>

```
$ kubectl get services -n bgd
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
bgd    NodePort   10.110.113.78   <none>        8080:32109/TCP   31s
```

<br/>

```
$ minikube --profile ${PROFILE} ip
192.168.58.2
```

<br/>

```
// [OK!]
http://192.168.58.2:32109
```

<br/>

```
$ argocd app set bgd-app --sync-policy manual
```

<br/>

```
$ kubectl -n bgd patch deploy/bgd \
--type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/env/0/value", "value":"red"}]'
```

<br/>

```
// [OK!]
http://192.168.58.2:32109
```

<br/>

```
$ argocd app delete bgd-app
```
