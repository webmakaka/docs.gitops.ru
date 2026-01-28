---
layout: page
title: GitOps Days 2021 Handling Dependencies with Flux
description: GitOps Days 2021 Handling Dependencies with Flux
keywords: linux, kubernetes, FluxCD, Kustomize, GitOps Days 2021 Handling Dependencies with Flux
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/cloud-native-applications-gitops-with-flux-and-flagger/
---

# [YouTube] Cloud Native Applications Gitops with Flux and Flagger

<br/>

https://www.youtube.com/watch?v=kbAKUKaMA1w

https://github.com/Tiggel/flux-app-demo/

<br/>

```
// Создается приватный репо flux-fleet
$ flux bootstrap github \
    --owner $GITHUB_USER \
    --repository flux-app-demo \
    --branch canary \
    --path "./config/play/flux" \
    --personal
```

<br/>

Меняем версию podinfo на 5.2.0 в branch canary

https://github.com/Tiggel/flux-app-demo/commit/69969f5818c3da7a14e4493fe0a74b086b753929

<br/>

https://docs.flagger.app/tutorials/istio-progressive-delivery

<br/>

```
$ flux reconcile ks canary --with-source
```

<br/>

```
$ watch curl http://podinfo-canary:9898/status/500
```
