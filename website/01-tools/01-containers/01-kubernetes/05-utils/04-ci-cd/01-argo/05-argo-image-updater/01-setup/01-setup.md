---
layout: page
title: Инсталляция Argo Events
description: Инсталляция Argo Events
keywords: devops, containers, kubernetes, Argo Events, setup
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argo-image-updater/setup/
---

# Инсталляция Argo Image Updater

<br/>

Делаю:  
2026.01.22

<br/>

https://argocd-image-updater.readthedocs.io/en/stable/

<br/>

```
$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml
```
