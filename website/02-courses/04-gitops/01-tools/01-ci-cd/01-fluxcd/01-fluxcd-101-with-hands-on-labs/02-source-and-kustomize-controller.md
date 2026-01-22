---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Source and Kustomize Controller
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/source-and-kustomize-controller/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

## 03. Source and Kustomize Controller

<br/>

### LAB 2 - Deploy Application Manifest - Flux Repo

<br/>

```
$ cd bb-app-source/
$ git switch 1-demo
$ git pull
```

<br/>

```
$ flux get sources git
NAME       	REVISION          	SUSPENDED	READY	MESSAGE
flux-system	main@sha1:9f2d417a	False    	True 	stored artifact for revision 'main@sha1:9f2d417a'
```

<br/>

```
$ flux get kustomization
NAME       	REVISION          	SUSPENDED	READY	MESSAGE
flux-system	main@sha1:9f2d417a	False    	True 	Applied revision: main@sha1:9f2d417a
```

<br/>

Скопировали манифесты из bb-app-source/manifests в каталог clusters/my-cluster/1-demo

commit / push

<br/>

```
// Должно появиться 1-demo
$ kubectl get ns
NAME                        STATUS   AGE
1-demo                      Active   28s
***
```

<br/>

```
$ kubectl -n 1-demo get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/block-buster-7c7c5bd4d8-2ggrb   1/1     Running   0          75s

NAME                           TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/block-buster-service   NodePort   10.108.171.222   <none>        80:30001/TCP   75s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/block-buster   1/1     1            1           75s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/block-buster-7c7c5bd4d8   1         1         1       75s
```

<br/>

```
$ export PROFILE=${USER}-minikube
$ minikube --profile ${PROFILE} ip
```

<br/>

```
// OK!
http://192.168.49.2:30001
```

<br/>

```
// Посмотреть где в итоге хранятся манифесты
$ kubectl -n flux-system get pods
$ kubectl -n flux-system exec -it source-controller-664f9c8869-c6nj8 -- sh
$ cd data/gitrepository/flux-system/flux-system/
$ ls
035ab64a849b04b2595d837e6a80d0eb4eb22001.tar.gz
035ab64a849b04b2595d837e6a80d0eb4eb22001.tar.gz.lock

$ tar -tf 035ab64a849b04b2595d837e6a80d0eb4eb22001.tar.gz
.
clusters
clusters/my-cluster
clusters/my-cluster/1-demo
clusters/my-cluster/1-demo/deployment.yml
clusters/my-cluster/1-demo/namespace.yml
clusters/my-cluster/1-demo/service.yml
clusters/my-cluster/flux-system
clusters/my-cluster/flux-system/gotk-components.yaml
clusters/my-cluster/flux-system/gotk-sync.yaml
clusters/my-cluster/flux-system/kustomization.yaml
```

<br/>

### LAB 3 - Deploy Application Manifest - External Git Repo

<br/>

```
$ git switch 2-demo
```

<br/>

```
// Посмотреть, но не создавать
$ flux create source git 2-demo-source-git-bb-app \
  --url https://github.com/wildmakaka/bb-app-source \
  --branch=2-demo \
  --timeout 10s \
  --export
```

<br/>

```
// Создать
$ flux create source git 2-demo-source-git-bb-app \
  --url https://github.com/wildmakaka/bb-app-source \
  --branch=2-demo \
  --timeout 10s
```

<br/>

```
$ flux get sources git
NAME                    	REVISION            	SUSPENDED	READY	MESSAGE
2-demo-source-git-bb-app	2-demo@sha1:310e0bea	False    	True 	stored artifact for revision '2-demo@sha1:310e0bea'
flux-system             	main@sha1:035ab64a  	False    	True 	stored artifact for revision 'main@sha1:035ab64a'
```

<br/>

```
$ flux delete source git 2-demo-source-git-bb-app
```

<br/>

```
$ cd ~/projects/fluxcd/block-buster/clusters/my-cluster/
```

<br/>

```
// Создать yaml
$ flux create source git 2-demo-source-git-bb-app \
  --url https://github.com/wildmakaka/bb-app-source \
  --branch=2-demo \
  --timeout 10s \
  --export > 2-demo-source-git-bb-app.yaml
```

<br/>

```
// Создать yaml
$ flux create kustomization 2-demo-source-git-bb-app \
  --source GitRepository/2-demo-source-git-bb-app \
  --prune true \
  --interval 10s \
  --target-namespace 2-demo \
  --path manifests \
  --export > 2-demo-kustomize-git-bb-app.yaml
```

<br/>

```
// Добавились новые REVISION
$ flux get sources git
$ flux get kustomizations
```

<br/>

```
$ kubectl get ns
NAME                        STATUS   AGE
1-demo                      Active   49m
2-demo                      Active   44s
***
```

<br/>

```
// OK!
http://192.168.49.2:30002
```

<br/>

```
$ kubectl -n 2-demo get all
```

<br/>

```
// Пришлось останавливать ранее запущенное приложение, т.к. мало cpu.
// OK!
http://192.168.49.2:30002
```

<br/>

### Продолжение

<br/>

```
$ git switch 3-demo
```

<br/>

```
$ cd ~/projects/fluxcd/block-buster/clusters/my-cluster/
```

<br/>

```
$ flux create source git 3-demo-source-git-bb-app \
  --url https://github.com/wildmakaka/bb-app-source \
  --branch=3-demo \
  --timeout 10s \
  --export > 3-demo-source-git-bb-app.yaml
```

<br/>

```
$ flux create kustomization 3-demo-source-git-bb-app \
  --source GitRepository/3-demo-source-git-bb-app \
  --prune true \
  --interval 10s \
  --target-namespace 3-demo \
  --path kustomize \
  --export > 3-demo-kustomize-git-bb-app.yaml
```

<br/>

```
$ flux get sources git
$ kubectl get ns
```

<br/>

```
$ kubectl -n 3-demo get all
```

<br/>

```
// Пришлось останавливать ранее запущенное приложение, т.к. мало cpu.
// OK!
http://192.168.49.2:30003
```

<br/>

### LAB 4 - Deploy Application Manifest from a S3 Repo

<br/>

```
$ git switch 4-demo
```

<br/>

```
$ kubectl apply -f minio/minio-s3.yaml
```

<br/>

```
$ kubectl -n minio-dev get all
```

<br/>

```
// OK!
// minioadmin / minioadmin
http://192.168.49.2:30040/
```

<br/>

```
Buckets -> create bucket
name: bucket-bb-app
```

<br/>

```
Object Browser -> Create new path
name: app-740
```

<br/>

```
Upload: manifests
```

<br/>

```
$ flux create source bucket 4-demo-source-minio-s3-bucket-bb-app \
  --bucket-name bucket-bb-app \
  --secret-ref minio-crds \
  --endpoint minio.minio-dev.svc.cluster.local:9000 \
  --provider generic \
  --insecure \
  --export > 4-demo-source-minio-s3-bucket-bb-app.yaml
```

<br/>

```
$ flux create kustomization 4-demo-kustomize-minio-s3-bucket-bb-app \
  --source Bucket/4-demo-source-minio-s3-bucket-bb-app \
  --target-namespace 4-demo \
  --path ./app-740 \
  --prune true \
  --export > 4-demo-kustomize-minio-s3-bucket-bb-app.yaml
```

<br/>

```
$ kubectl -n flux-system create secret generic minio-crds \
    --from-literal=accesskey=minioadmin \
    --from-literal=secretkey=minioadmin
```

<br/>

commit / push

<br/>

```
$ flux get source bucket
NAME                                	REVISION       	SUSPENDED	READY	MESSAGE
4-demo-source-minio-s3-bucket-bb-app	sha256:cce16a8a	False    	True 	stored artifact: revision 'sha256:cce16a8a'
```

<br/>

```
// При необходимости
$ flux reconcile source bucket 4-demo-source-minio-s3-bucket-bb-app
```

<br/>

```
$ kubectl -n 4-demo get all
```

<br/>

```
// Пришлось останавливать ранее запущенное приложение, т.к. мало cpu.
// OK!
http://192.168.49.2:30004
```
