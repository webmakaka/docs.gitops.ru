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

// https://github.com/argoproj-labs/argocd-image-updater/blob/release-0.18/manifests/install.yaml

$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/refs/heads/release-0.18/manifests/install.yaml
```

<br/>

```
// Так не заработало с аннотациями
// Считается уже устарашей
// Надо будет разобраться и обновиться
// $ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml
```
