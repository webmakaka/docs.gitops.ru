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

<br/>

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

<br/>

**Делаю:**  
2026.01.27

<br/>

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
    helm:
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

<br/>

## Chapter 08 Argo CD - Private Repositories

<br/>

**Делаю:**  
2026.01.28

<br/>

### 003. Lab - Private Repos via HTTPS

<br/>

Создаю приватное репо: argocd-course-private-repo-demo

Копирую в него каталог: https://github.com/lm-academy/argocd-example-apps/tree/master/helm-guestbook

Создаю PAT:

https://github.com/settings/tokens

<br/>

```
Token name: argocd-private-repo-https

Repository access: Only select repositories

Add permission: Contents (Read-only)
```

<br/>

**1. Способ в UI**

```
ARGO -> Settings -> Repositories -> Connect Reposistories

Chose your connection method: VIA HTTP/HTTPS

Type: git

Project: default

Repository URL: https://github.com/wildmakaka/argocd-course-private-repo-demo.git

Username: wildmakaka

Passsword: PAT

Connect
```

<br/>

**2. Способ в CLI**

<br/>

```
$ export GITHUB_PAT=<YOUR_GITHUB_PAT>
$ kubectl create secret generic private-repo-https --from-literal type=git --from-literal password=${GITHUB_PAT} --from-literal username=wildmakaka --from-literal url=https://github.com/wildmakaka/argocd-course-private-repo-demo.git -n argocd
$ kubectl label secret private-repo-https argocd.argoproj.io/secret-type=repository -n argocd
```

<br/>

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
    repoURL: https://github.com/wildmakaka/argocd-course-private-repo-demo.git
    targetRevision: HEAD
    path: helm-guestbook
    helm:
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

```
$ kubectl get pods -n default
NAME                                        READY   STATUS    RESTARTS   AGE
guestbook-helm-guestbook-5b66c4c879-xbc9x   1/1     Running   0          96s
```

<br/>

### 008. Lab - Private Repos via SSH

<br/>

```
$ mkdir .ssh
$ ssh-keygen -t ed25519 -C "argocd-deploy-key" -f ./.ssh/argocd-deploy-key
```

<br/>

```
// Скопировать public key в буфер
$ cat ./.ssh/argocd-deploy-key.pub | xclip -selection clipboard
```

<br/>

```
Github -> Project -> Settings -> Deploy Keys

https://github.com/wildmakaka/argocd-course-private-repo-demo/settings/keys

Title: argocd-deploy-key
Key: Public Key

Add key
```

<br/>

**1. Способ в UI**

```
ARGO -> Settings -> Repositories -> Connect Reposistories

Chose your connection method: VIA SSH

Project: default

Repository URL: git@github.com:wildmakaka/argocd-course-private-repo-demo.git

SSH private key data: OPENSSH PRIVATE KEY

Username: wildmakaka

Passsword: PAT

Connect
```

<br/>

**2. Способ в CLI**

<br/>

```
$ PRIVATE_KEY=$(cat .ssh/argocd-deploy-key)
$ echo ${PRIVATE_KEY}
$ kubectl create secret generic private-repo-ssh --from-literal type=git --from-literal url=git@github.com:wildmakaka/argocd-course-private-repo-demo.git --from-literal sshPrivateKey="${PRIVATE_KEY}" -n argocd
$ kubectl label secret private-repo-ssh argocd.argoproj.io/secret-type=repository -n argocd
```

<br/>

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
    repoURL: git@github.com:wildmakaka/argocd-course-private-repo-demo.git
    targetRevision: HEAD
    path: helm-guestbook
    helm:
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

<br/>

```
$ kubectl get pods -n default
NAME                                        READY   STATUS    RESTARTS   AGE
guestbook-helm-guestbook-5b66c4c879-xbc9x   1/1     Running   0          34m
```

<br/>

## Chapter 09 Argo CD - Application Orchestration

<br/>

**Делаю:**  
2026.01.28

<br/>

### 003. Lab - Configuring Projects

<br/>

```
$ argocd proj list
$ argocd get default
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: finance
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-finance
  namespace: argocd
spec:
  description: Project for Team Finance with security guardrails
  sourceRepos:
  - "https://github.com/lm-academy/argocd-example-apps.git"
  destinations:
  - server: https://kubernetes.default.svc
    namespace: finance

  # clusterResourceWhitelist:
  #   - group: "*"
  #     kind: "*"

  namespaceResourceWhitelist:
    - group: "*"
      kind: "*"
EOF
```

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: team-finance
  source:
    repoURL: https://github.com/lm-academy/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: finance
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

<br/>

### 008. Lab - Implementing Sync Hooks
