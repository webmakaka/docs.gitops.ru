---
layout: page
title: Инсталляция fluxcd
description: Инсталляция fluxcd
keywords: linux, kubernetes, fluxcd, setup
permalink: /tools/containers/kubernetes/utils/ci-cd/fluxcd/setup/
---

# Инсталляция fluxcd

<br/>

Делаю:  
29.04.2023

<br/>

```
$ curl -s https://fluxcd.io/install.sh | sudo bash
```

<br/>

```
$ flux --version
flux version 2.0.0-rc.1
```

<br/>

Github -> Settings -> Developer Settings -> Personal access tokens -> Tokens (classic) -> Generate new token (classic)

Name: FLUXCD

```
v repo
```

Generate Token

<br/>

```
$ mkdir -p ~/projects/dev/fluxcd
$ cd ~/projects/dev/fluxcd
```

<br/>

```
$ export GITHUB_USER=fleet-infra
$ export REPOSITORY_NAME=block-buster
```

<br/>

```
$ flux bootstrap github \
  --owner=${GITHUB_USER} \
  --repository=${REPOSITORY_NAME} \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```

<br/>

```
$ git clone git@github.com:wildmakaka/block-buster.git
```

<br/>

```
// После развертывания предоставит данные
$ flux version
flux: v2.0.0-rc.1
helm-controller: v0.32.1
kustomize-controller: v1.0.0-rc.1
notification-controller: v1.0.0-rc.1
source-controller: v1.0.0-rc.1
```

<br/>

```
$ kubectl -n flux-system get all
```

<br/>

```
$ kubectl get crds | grep -i flux
alerts.notification.toolkit.fluxcd.io                 2023-04-29T16:41:00Z
buckets.source.toolkit.fluxcd.io                      2023-04-29T16:41:00Z
gitrepositories.source.toolkit.fluxcd.io              2023-04-29T16:41:00Z
helmcharts.source.toolkit.fluxcd.io                   2023-04-29T16:41:00Z
helmreleases.helm.toolkit.fluxcd.io                   2023-04-29T16:41:00Z
helmrepositories.source.toolkit.fluxcd.io             2023-04-29T16:41:00Z
kustomizations.kustomize.toolkit.fluxcd.io            2023-04-29T16:41:00Z
ocirepositories.source.toolkit.fluxcd.io              2023-04-29T16:41:00Z
providers.notification.toolkit.fluxcd.io              2023-04-29T16:41:00Z
receivers.notification.toolkit.fluxcd.io              2023-04-29T16:41:01Z
```
