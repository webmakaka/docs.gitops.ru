---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Secret Management & Sign Verification, setup
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/secret-management-and-sign-verification/setup/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

Все нафиг удаляю.

<br/>

[Подготавливаю чистое окружение!](/courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/setup/)

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/
$ git switch infrastructure
$ cd database/
```

<br/>

```
$ vi secret-mysql.yaml
```

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
$ rm sops-secret-mysql.yml
```

<br/>

commit / push

<br/>

```
$ cd ~/projects/dev/fluxcd/block-buster/flux-clusters/dev-cluster/
```

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
$ flux create source git 8-demo-source-git-bb-app \
  --url ssh://git@github.com/wildmakaka/bb-app-source.git \
  --branch 8-demo \
  --timeout 10s \
  --secret-ref 8-demo-git-bb-app-auth \
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

### Поднимаем базу MySQL

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
// OK!
// # mysql --host=localhost --user=root --password=mysql-password-0123456789 bricks
# mysql --host=mysql.database.svc.cluster.local --user=root --password=mysql-password-0123456789 bricks
```

<br/>

```
// OK!
http://192.168.49.2:30008/
```
