---
layout: page
title: Argo CD - Up & Running - Synchronizing Applications
description: Argo CD - Up & Running - Synchronizing Applications
keywords: books, ci-cd, argocd, Argo CD - Up and Running - A Hands-On Guide to GitOps and Kubernetes, Synchronizing Applications
permalink: /books/containers/kubernetes/utils/ci-cd/argo-cd/argocd-up-and-running/synchronizing-applications/
---

# [Book][Andrew Block, Christian Hernandez] Argo CD: Up and Running: A Hands-On Guide to GitOps and Kubernetes [ENG, 2025]

<br/>

### Chapter 4: Synchronizing Applications

<br/>

**Делаю:**  
2025.12.09

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: pricelist-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: ch05/manifests/
    repoURL: https://github.com/sabre1041/argocd-up-and-running-book
    targetRevision: main
  destination:
    namespace: pricelist
    name: in-cluster
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF
```

<br/>

На стенде в нужном порядке стартовали pod. В базу данных записались данные.
