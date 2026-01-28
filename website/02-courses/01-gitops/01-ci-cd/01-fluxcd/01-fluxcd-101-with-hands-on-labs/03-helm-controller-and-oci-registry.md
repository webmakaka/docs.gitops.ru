---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Helm Controller and OCI Registry
permalink: /courses/gitops/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/helm-controller-and-oci-registry/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

## 04. Helm Controller and OCI Registry

<br/>

**Чистка от предыдущих лаб**

```
$ flux get sources all
```

<br/>

```
$ flux get sources bucket
$ flux delete source bucket 4-demo-source-minio-s3-bucket-bb-app
```

<br/>

```
$ flux get sources git
$ flux delete source git 2-demo-source-git-bb-app
$ flux delete source git 3-demo-source-git-bb-app
```

<br/>

```
$ flux get kustomization
$ flux delete kustomization 2-demo-source-git-bb-app
$ flux delete kustomization 3-demo-source-git-bb-app
$ flux delete kustomization 4-demo-kustomize-minio-s3-bucket-bb-app
```

<br/>

### LAB 5 - Deploy Helm Charts from a Helm Repository

<br/>

```
$ git switch 5-demo
```

<br/>

```
$ flux create source git 5-demo-source-git-helm-bb-app \
  --url https://github.com/wildmakaka/bb-app-source \
  --branch=5-demo \
  --timeout 10s \
  --export > 5-demo-source-git-helm-bb-app.yaml
```

<br/>

```
$ vi 5-demo-values.yaml
```

```yaml
replicaCount: 2

service:
  type: NodePort
  nodePort: 30005

namespace:
  name: 5-demo

labels:
  app:
    name: block-buster
    version: 7.5.0
    env: dev
```

<br/>

```
$ flux create helmrelease 5-demo-helm-release-git-helm-bb-app \
  --chart helm-chart \
  --interval 10s \
  --target-namespace 5-demo \
  --source GitRepository/5-demo-source-git-helm-bb-app \
  --values 5-demo-values.yaml \
  --export > 5-demo-helm-release-git-helm-bb-app.yaml
```

<br/>

```
// Пока не удалил файл 5-demo-values.yaml, ничего не запускалось
$ rm 5-demo-values.yaml
```

<br/>

commit / push

<br/>

```
$ flux get sources git 5-demo-source-git-helm-bb-app
NAME                         	REVISION            	SUSPENDED	READY	MESSAGE
5-demo-source-git-helm-bb-app	5-demo@sha1:d327af27	False    	True 	stored artifact for revision '5-demo@sha1:d327af27'
```

<br/>

```
$ flux get helmreleases
NAME                               	REVISION	SUSPENDED	READY	MESSAGE
5-demo-helm-release-git-helm-bb-app	7.5.0   	False    	True 	Release reconciliation succeeded
```

<br/>

```
// OK!
http://192.168.49.2:30005/
```

<br/>

```
// labels подтянулись из файла 5-demo-values.yaml
$ kubectl -n 5-demo get pods --show-labels
NAME                                     READY   STATUS    RESTARTS   AGE    LABELS
block-buster-helm-app-6d69ff466d-bjq5x   1/1     Running   0          7m4s   app=block-buster,env=dev,pod-template-hash=6d69ff466d,version=7.5.0
block-buster-helm-app-6d69ff466d-vfhn2   1/1     Running   0          7m4s   app=block-buster,env=dev,pod-template-hash=6d69ff466d,version=7.5.0
```

<br/>

```
$ flux get sources chart
NAME                                           	REVISION	SUSPENDED	READY	MESSAGE
flux-system-5-demo-helm-release-git-helm-bb-app	7.5.0   	False    	True 	packaged 'block-buster-helm-app' chart with version '7.5.0'
```

<br/>

```
$ kubectl -n flux-system get helmcharts.source.toolkit.fluxcd.io
NAME                                              CHART        VERSION   SOURCE KIND     SOURCE NAME                     AGE   READY   STATUS
flux-system-5-demo-helm-release-git-helm-bb-app   helm-chart   *         GitRepository   5-demo-source-git-helm-bb-app   12m   True    packaged 'block-buster-helm-app' chart with version '7.5.0'
```

<br/>

```
$ kubectl -n flux-system get helmcharts.source.toolkit.fluxcd.io -o yaml
```

<br/>

### Продолжение

<br/>

https://sidd-harth.github.io/block-buster-helm-app/

https://artifacthub.io/packages/helm/block-buster-app/block-buster-helm-app

<br/>

```
$ flux create source helm 6-demo-source-helm-bb-app \
  --url https://sidd-harth.github.io/block-buster-helm-app \
  --timeout 10s \
  --export > 6-demo-source-helm-bb-app.yaml
```

<br/>

```
$ vi 6-demo-values.yaml
```

```yaml
replicaCount: 1

service:
  type: NodePort
  nodePort: 30006

namespace:
  name: 6-demo

labels:
  app:
    name: block-buster
    version: 7.6.0
    env: dev
```

<br/>

```
$ flux create helmrelease 6-demo-helm-release-bb-app \
  --chart block-buster-helm-app \
  --interval 10s \
  --target-namespace 6-demo \
  --source HelmRepository/6-demo-source-helm-bb-app \
  --values 6-demo-values.yaml \
  --export > 6-demo-helm-release-bb-app.yaml
```

<br/>

```
$ rm 6-demo-values.yaml
```

<br/>

```
// OK!
http://192.168.49.2:30006/
```

<br/>

```
$ flux get helmreleases
NAME                      	REVISION	SUSPENDED	READY	MESSAGE
6-demo-helm-release-bb-app	7.6.0   	False    	True 	Release reconciliation succeeded
```

<br/>

### 07. DEMO - Push Kubernetes Manifest to OCI Registry

<br/>

github -> edit token ->

```
v write:packages
v delete:packages
```

<br/>

```
$ git switch 7-demo
```

<br/>

```
// Нужно токен вводить!
$ docker login ghcr.io --username wildmakaka
```

<br/>

```
// Создать приватный package в github
$ flux push artifact oci://ghcr.io/wildmakaka/bb-app:7.7.0-$(git rev-parse --short HEAD) \
  --path="./7.7.0/manifests" \
  --source="$(git config --get remote.origin.url)" \
  --revision="7.7.0/$(git rev-parse --short HEAD)"
```

<br/>

### 08. DEMO - Push Helm Chart to OCI Registry

<br/>

[Устанавливаю helm](//docs.k8s.ru/tools/containers/kubernetes/utils/helm/setup/)

<br/>

```
$ helm package 7.7.1/helm-chart/
```

<br/>

```
// Нужно токен вводить!
$ helm registry login ghcr.io --username wildmakaka
```

<br/>

```
$ helm push block-buster-helm-app-7.7.1.tgz oci://ghcr.io/wildmakaka/bb-app
```

<br/>

### 09. DEMO - Setting up the MySQL Database

<br/>

```
$ git switch infrastructure
```

<br/>

```
$ flux create source git infra-source-git \
  --url https://github.com/wildmakaka/bb-app-source \
  --branch=infrastructure \
  --timeout 10s \
  --export > infra-source-git.yaml
```

<br/>

```
$ flux create kustomization infra-database-kustomize-git-mysql \
  --source GitRepository/infra-source-git \
  --prune true \
  --interval 10s \
  --target-namespace database \
  --path ./database \
  --export > infra-database-kustomize-git-mysql.yaml
```

<br/>

commit / push

<br/>

```
$ flux reconcile source git flux-system
```

<br/>

```
$ flux get sources git infra-source-git
NAME            	REVISION                    	SUSPENDED	READY	MESSAGE
infra-source-git	infrastructure@sha1:9d811936	False    	True 	stored artifact for revision 'infrastructure@sha1:9d811936'
```

<br/>

```
$ flux get kustomization infra-database-kustomize-git-mysql
NAME                              	REVISION                    	SUSPENDED	READY	MESSAGE
infra-database-kustomize-git-mysql	infrastructure@sha1:9d811936	False    	True 	Applied revision: infrastructure@sha1:9d811936
```

<br/>

**Если не будет подключаться, можно попробовать сделать следующее! У меня заработало.**

<br/>

github.com -> bb-app-source -> infrastructure -> database -> secret-mysql.yaml

<br/>

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-mysql
  namespace: database
stringData:
  password: mysql-password-0123456789
```

<br/>

```
// OK!
// # mysql --host=localhost --user=root --password=mysql-password-0123456789 bricks
# mysql --host=mysql.database.svc.cluster.local --user=root --password=mysql-password-0123456789 bricks
```

<br/>

М.б. еще придется пересоздать приложение с указанием нужного пароля.

<br/>

### 10. DEMO - Flux Pull and Deploy from OCI Registry

<br/>

```
$ flux create secret oci ghcr-auth \
  --url ghcr.io \
  --username wildmakaka \
  --password <GITHUB_TOKEN>
```

<br/>

```
$ kubectl -n flux-system get secrets
***
ghcr-auth
***
```

<br/>

```
// tag взять в packages на github
$ flux create source oci 7-demo-source-oci-bb-app-7-7-0 \
  --url oci://ghcr.io/wildmakaka/bb-app \
  --tag 7.7.0-0bb2691 \
  --secret-ref ghcr-auth \
  --provider generic \
  --export > 7-demo-source-oci-bb-app-7-7-0.yaml
```

<br/>

```
$ flux create kustomization 7-demo-kustomize-oci-bb-app-7-7-0 \
  --source OCIRepository/7-demo-source-oci-bb-app-7-7-0 \
  --target-namespace 7-demo \
  --interval 10s \
  --prune false \
  --health-check='Deployment/block-buster-7-7-0.7-demo' \
  --depends-on infra-database-kustomize-git-mysql \
  --timeout 2m \
  --export > 7-demo-kustomize-oci-bb-app-7-7-0.yaml
```

<br/>

commit / push

<br/>

```
$ flux get kustomization 7-demo-kustomize-oci-bb-app-7-7-0
NAME                             	REVISION	SUSPENDED	READY  	MESSAGE
7-demo-kustomize-oci-bb-app-7-7-0	        	False    	Unknown	Reconciliation in progress
```

<br/>

```
$ kubectl -n flux-system get kustomizations.kustomize.toolkit.fluxcd.io
NAME                                 AGE    READY     STATUS
7-demo-kustomize-oci-bb-app-7-7-0    10m    Unknown   Reconciliation in progress
flux-system                          26h    True      Applied revision: main@sha1:9ba1fed9213b525c556776a983d5c9784d296bcc
infra-database-kustomize-git-mysql   142m   True      Applied revision: infrastructure@sha1:9d811936cedf54261faf3786c042d9b35cce950f
```

<br/>

```
// Чекаем ошибку
$ kubectl -n flux-system get kustomizations.kustomize.toolkit.fluxcd.io 7-demo-kustomize-oci-bb-app-7-7-0 -o yaml
```

<br/>

```
$ flux reconcile source git flux-system
$ flux reconcile kustomization 7-demo-kustomize-oci-bb-app-7-7-0
```

<br/>

```
// OK!
http://192.168.49.2:30770/
```
