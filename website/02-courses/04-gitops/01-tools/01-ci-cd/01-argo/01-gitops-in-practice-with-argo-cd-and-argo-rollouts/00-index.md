---
layout: page
title: GitOps in Practice with Argo CD and Argo Rollouts
description: GitOps in Practice with Argo CD and Argo Rollouts
keywords: courses, gitops, argo, GitOps in Practice with Argo CD and Argo Rollouts
permalink: /courses/gitops/tools/ci-cd/argo/gitops-in-practice-with-argo-cd-and-argo-rollouts/
---

# [Lauro Fialho Müller] GitOps in Practice with Argo CD and Argo Rollouts [ENG, 2026]

<br/>

https://github.com/lm-academy/argocd-course

https://github.com/lm-academy/argo-rollouts-course

https://github.com/lm-academy/argocd-example-apps

https://github.com/lm-academy/argocd-example-apps-labs

<br/>

https://github.com/PacktPublishing/GitOps-in-Practice-with-Argo-CD-and-Argo-Rollouts-The-Complete-Guide

<br/>

## Chapter 05 Argo CD - Core Concepts

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/lm-academy/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
EOF
```

<br/>

```
$ argocd login <ARGOCD_HOST>
$ argocd app list
$ argocd app sync guestbook
```

<br/>

```
$ kubectl port-forward svc/guestbook-ui 8080:80
```

<br/>

```
http://localhost:8080
```

<br/>

## Chapter 06 Argo CD - Helm Integration

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/lm-academy/argocd-example-apps.git
    targetRevision: HEAD
    path: helm-guestbook
    valueFiles:
      - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

### 006. Lab - Deploying Public Helm Charts - Solution

https://github.com/lm-academy/argocd-course/tree/main/public-helm-charts/manifests

https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard

<br/>

```
$ kubectl create token   k8s-dashboard-view -n k8s-dashboard
```

<br/>

```
$ argocd app sync k8s-dashboard
```

<br/>

```
$ kubectl port-forward src/k8s-dashboard-kong-proxy 8443:443 -n k8s-dashboard
```

<br/>

```
http://localhost:8443
```

<br/>

```
$ kubectl get clusterrole
$ kubectl get clusterrole -o yaml
```

<br/>

```
$ kubectl describe clusterrole view
```
