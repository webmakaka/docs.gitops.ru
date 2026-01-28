---
layout: page
title: Инсталляция Argo Events
description: Инсталляция Argo Events
keywords: devops, containers, kubernetes, Argo Events, setup
permalink: /tools/gitops/ci-cd/argo/argo-image-updater/setup/
---

# Инсталляция Argo Image Updater

<br/>

**Делаю:**  
2025.12.04

<br/>

https://github.com/argoproj-labs/argocd-image-updater

<br/>

https://argocd-image-updater.readthedocs.io/en/stable/basics/update-methods/

<br/>

С версии v1.0.0 Image Updater перешел на использование отдельных ImageUpdater CRD, а не аннотаций в Application ресурсах.

<br/>

```
$ helm repo add argo https://argoproj.github.io/argo-helm
```

<br/>

```
$ helm install argocd-image-updater argo/argocd-image-updater \
 --namespace argocd \
 --set argocd.insecure=true
```

<br/>

```
$ kubectl get crd | grep imageupdater
imageupdaters.argocd-image-updater.argoproj.io   2025-12-04T02:17:18Z
```

<br/>

## Вариант, когда нужно работать с аннотациями

<br/>

**Делаю:**  
2026.01.22

https://argocd-image-updater.readthedocs.io/en/stable/

<br/>

```
// https://github.com/argoproj-labs/argocd-image-updater/blob/release-0.18/manifests/install.yaml

$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/refs/heads/release-0.18/manifests/install.yaml
```
