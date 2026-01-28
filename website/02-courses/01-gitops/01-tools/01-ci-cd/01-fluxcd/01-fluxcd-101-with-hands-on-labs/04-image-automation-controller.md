---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Image Automation Controller
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/image-automation-controller/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

## 05. Image Automation Controller

<br/>

### 02. DEMO - Install Image Automation Controller

<br/>

```
$ export GITHUB_USER=wildmakaka
$ export REPOSITORY_NAME=block-buster
```

<br/>

```
$ flux bootstrap github \
  --owner=${GITHUB_USER} \
  --repository=${REPOSITORY_NAME} \
  --branch=main \
  --path=flux-clusters/dev-cluster \
  --personal \
  --private=false \
  --components-extra="image-reflector-controller,image-automation-controller"
```

<br/>

```
$ kubectl -n flux-system get po,deploy
NAME                                               READY   STATUS    RESTARTS   AGE
pod/helm-controller-7cbfc44f88-9zsrk               1/1     Running   0          116m
pod/image-automation-controller-679b595d96-h77sm   1/1     Running   0          111s
pod/image-reflector-controller-9b7d45fc5-shqjx     1/1     Running   0          111s
pod/kustomize-controller-76dd89c9d4-4bvbh          1/1     Running   0          116m
pod/notification-controller-86d886486b-2wz5t       1/1     Running   0          116m
pod/source-controller-7cfdc467d6-g8nsl             1/1     Running   0          116m

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helm-controller               1/1     1            1           116m
deployment.apps/image-automation-controller   1/1     1            1           111s
deployment.apps/image-reflector-controller    1/1     1            1           111s
deployment.apps/kustomize-controller          1/1     1            1           116m
deployment.apps/notification-controller       1/1     1            1           116m
deployment.apps/source-controller             1/1     1            1           116m
```

<br/>

```
$ kubectl get crds | grep image
imagepolicies.image.toolkit.fluxcd.io            2023-04-30T22:29:44Z
imagerepositories.image.toolkit.fluxcd.io        2023-04-30T22:29:44Z
imageupdateautomations.image.toolkit.fluxcd.io   2023-04-30T22:29:44Z
```

<br/>

```
$ cd block-buster/
$ git pull
```

<br/>

### 03. DEMO - Initialize DockerHub

<br/>

```
$ git switch 8-demo
```

<br/>

```
$ docker logout
```

<br/>

```
$ docker login
```

<br/>

```
$ docker pull siddharth67/block-buster-dev:7.8.0
$ docker tag siddharth67/block-buster-dev:7.8.0 webmakaka/bb-app-flux-demo:7.8.0
$ docker push webmakaka/bb-app-flux-demo:7.8.0
```

<br/>

```
$ cd bb-app-source
$ vi manifests/deployment.yml
```

<br/>

Прописываю:

```
image: webmakaka/bb-app-flux-demo:7.8.0
```

<br/>

commit / push

<br/>

```
$ flux create source git 8-demo-source-git-bb-app \
  --url https://github.com/wildmakaka/bb-app-source \
  --branch=8-demo \
  --timeout 10s \
  --export > 8-demo-source-git-bb-app.yaml
```

<br/>

```
$ flux create kustomization 8-demo-kustomize-git-bb-app \
  --source GitRepository/8-demo-source-git-bb-app \
  --target-namespace 8-demo \
  --prune true \
  --interval 10s \
  --path manifests \
  --export > 8-demo-kustomize-git-bb-app.yaml
```

<br/>

commit / push

<br/>

```
$ flux reconcile source git flux-system
```

<br/>

```
// OK!
http://192.168.49.2:30008/
```

<br/>

### 04. DEMO - Image Automation Controller - Repository

<br/>

```
$ flux create image repository 8-demo-image-repo-bb-app \
  --image docker.io/webmakaka/bb-app-flux-demo \
  --interval 10s \
  --export > 8-demo-image-repo-bb-app.yaml
```

<br/>

commit / push

<br/>

```
$ flux reconcile source git flux-system
```

<br/>

```
$ flux get image all
NAME                                    	LAST SCAN                	SUSPENDED	READY	MESSAGE
imagerepository/8-demo-image-repo-bb-app	2023-05-01T02:26:39+03:00	False    	True 	successful scan: found 1 tags
```

<br/>

```
$ cd bb-app-source
$ vi src/index.php
```

Меняю:

```
<body style="background-color: #80F1BE">
```

на

```
<body style="background-color: #A01B40">
```

<br/>

```
$ cd src/
$ docker build -t webmakaka/bb-app-flux-demo:7.8.1 .
$ docker push webmakaka/bb-app-flux-demo:7.8.1
```

<br/>

```
$ flux reconcile image repository 8-demo-image-repo-bb-app
$ kubectl -n flux-system get imagerepositories.image.toolkit.fluxcd.io 8-demo-image-repo-bb-app
$ kubectl -n flux-system get imagerepositories.image.toolkit.fluxcd.io 8-demo-image-repo-bb-app -o yaml
```

<br/>

Смотрим:

```
  lastScanResult:
    latestTags:
    - 7.8.1
    - 7.8.0
```

<br/>

### 06. DEMO - Image Automation Controller - Policy

<br/>

```
$ flux create image policy 8-demo-image-policy-bb-app \
  --image-ref=8-demo-image-repo-bb-app \
  --select-semver 7.8.x \
  --export > 8-demo-image-policy-bb-app.yaml
```

<br/>

```
$ flux get image all
NAME                                    	LAST SCAN                	SUSPENDED	READY	MESSAGE
imagerepository/8-demo-image-repo-bb-app	2023-05-01T02:45:18+03:00	False    	True 	successful scan: found 2 tags

NAME                                  	LATEST IMAGE                              	READY	MESSAGE
imagepolicy/8-demo-image-policy-bb-app	docker.io/webmakaka/bb-app-flux-demo:7.8.1	True 	Latest image tag for 'docker.io/webmakaka/bb-app-flux-demo' resolved to 7.8.1
```

<br/>

```
$ kubectl -n flux-system get imagepolicies.image.toolkit.fluxcd.io 8-demo-image-policy-bb-app -o yaml
```

<br/>

```
$ kubectl -n 8-demo get deploy block-buster -o wide
NAME           READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                             SELECTOR
block-buster   1/1     1            1           55m   app          webmakaka/bb-app-flux-demo:7.8.0   app=block-buster
```

<br/>

### 08. DEMO - Image Automation Controller - Update

<br/>

```
$ flux create image update 8-demo-image-update-bb-app \
  --git-repo-ref 8-demo-source-git-bb-app \
  --checkout-branch 8-demo \
  --author-name fluxcdbot \
  --author-email fluxcdbot@users.noreply.github.com \
  --git-repo-path ./manifests \
  --push-branch 8-demo \
  --interval 100s \
  --export > 8-demo-image-update-bb-app.yaml
```

<br/>

```
$ flux reconcile source git flux-system
$ flux get images all
```

<br/>

```
$ cd bb-app-source
$ vi manifests/deployment.yml
```

```
// Добавляем инструкции после тега
image:·webmakaka/bb-app-flux-demo:7.8.0 # {"$imagepolicy": "flux-system:8-demo-image-policy-bb-app"}
```

<br/>

commit / push

<br/>

```
$ flux reconcile source git 8-demo-source-git-bb-app
```

<br/>

```
$ flux get images all

***
authentication required
```

<br/>

```
$ kubectl -n flux-system get imageupdateautomations.image.toolkit.fluxcd.io 8-demo-image-update-bb-app -o yaml
```

<br/>

```
 message: authentication required
    reason: ReconciliationFailed
    status: "False"
    type: Ready
```

<br/>

github -> bb-app-source
-> 8-demo -> Settings -> Deploy keys

Будем во flux генерить!

<br/>

```
$ flux create secret git 8-demo-git-bb-app-auth \
  --url=ssh://git@github.com/wildmakaka/bb-app/source.git \
  --ssh-key-algorithm=ecdsa \
  --ssh-ecdsa-curve=p521
```

<br/>

Output вставляем в github.

GITHUB_USERNAME -> bb-app-source -> Settings -> Deploy keys -> Add deploy key

```
Title: FLUX UPDATE DEPLOY KEY

+ allow write
```

<br/>

```
$ kubectl -n flux-system get secrets 8-demo-git-bb-app-auth
NAME                     TYPE     DATA   AGE
8-demo-git-bb-app-auth   Opaque   3      65s
```

<br/>

```
// По http перестает работать, нужно сделать по ssh
$ flux create source git 8-demo-source-git-bb-app \
  --url ssh://git@github.com/wildmakaka/bb-app-source.git \
  --branch 8-demo \
  --timeout 10s \
  --secret-ref 8-demo-git-bb-app-auth \
  --export > 8-demo-source-git-bb-app.yaml
```

<br/>

commit / push

<br/>

```
$ kubectl -n 8-demo get deploy -o wide
NAME           READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                             SELECTOR
block-buster   1/1     1            1           133m   app          webmakaka/bb-app-flux-demo:7.8.0   app=block-buster
```

<br/>

```
$ flux get image update
NAME                      	LAST RUN                 	SUSPENDED	READY	MESSAGE
8-demo-image-update-bb-app	2023-05-01T04:06:24+03:00	False    	True 	no updates made; last commit 28a83c6 at 2023-05-01T01:05:46Z
```

<br/>

Бот обновил версию image в бранче 8-demo.

<br/>

```
$ kubectl -n 8-demo get deploy -o wide
NAME           READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                                       SELECTOR
block-buster   1/1     1            1           137m   app          docker.io/webmakaka/bb-app-flux-demo:7.8.1   app=block-buster
```

<br/>

```
// OK!
http://192.168.49.2:30008/
```
