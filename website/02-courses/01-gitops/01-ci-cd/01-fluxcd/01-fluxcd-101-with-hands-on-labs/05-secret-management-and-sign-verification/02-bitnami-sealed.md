---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Secret Management & Sign Verification, Bitnami Sealed
permalink: /courses/gitops/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/secret-management-and-sign-verification/bitnami-sealed/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

## Bitnami Sealed

<br/>

### 02. DEMO - Setup Bitnami Sealed

<br/>

```
$ flux create kustomization infra-security-kustomize-git-sealed-secrets \
  --source GitRepository/infra-source-git \
  --prune true \
  --interval 1h \
  --path ./bitnami-sealed-secrets \
  --export > infra-security-kustomize-git-sealed-secrets.yaml
```

<br/>

commit / push

<br/>

```
$ flux reconcile source git flux-system
```

<br/>

```
$ kubectl -n kube-system get all
```

<br/>

```
$ kubectl -n kube-system get secret
NAME                      TYPE                            DATA   AGE
bootstrap-token-l3do97    bootstrap.kubernetes.io/token   6      11h
sealed-secrets-keyxkmnn   kubernetes.io/tls               2      64s
```

<br/>

### [Установка kubeseal](//docs.k8s.ru/tools/containers/kubernetes/utils/security/bitnami-seal/)

<br/>

```
// Выдаст public / private keys
$ kubectl -n kube-system get secret sealed-secrets-keyxkmnn -o yaml
```

<br/>

```
// Выведет публичный ключ в консоль
$ kubeseal \
  --fetch-cert \
  --controller-name sealed-secrets-controller \
  --controller-namespace kube-system
```

<br/>

```
$ kubeseal \
  --fetch-cert \
  --controller-name sealed-secrets-controller \
  --controller-namespace kube-system > sealed-secret.pub
```

<br/>

### 03. DEMO - EncryptDecrypt Secret using Bitnami Sealed Secrets

<br/>

```
// Отключаем, чтобы не переосздавался
$ flux suspend kustomization infra-database-kustomize-git-mysql
$ flux get kustomizations infra-database-kustomize-git-mysql
```

<br/>

```
// Удаляем secret
$ kubectl -n database delete secrets secret-mysql
```

<br/>

```
$ kubectl -n database get po,secrets,deploy
NAME                         READY   STATUS    RESTARTS        AGE
pod/mysql-5775767668-n2lql   1/1     Running   1 (6h28m ago)   12h

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mysql   1/1     1            1           12h
```

<br/>

```
$ kubectl -n database rollout restart deployment mysql
```

<br/>

```
$ kubectl -n database describe pod mysql-77467b595-5wmmc
***
Failed *** Error: secret "secret-mysql" not found
***
```

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/infrastructure/database
$ kubeseal -o yaml --scope cluster-wide \
  --cert /home/marley/projects/dev/fluxcd/block-buster/clusters/my-cluster/sealed-secret.pub < secret-mysql.yaml > sealed-secret-mysql.yaml
```

<br/>

```
$ rm secret-mysql.yaml
```

<br/>

commit / push

<br/>

```
$ flux reconcile source git flux-system
$ flux resume kustomization infra-database-kustomize-git-mysql
```

<br/>

```
$ kubectl -n database get secrets
NAME           TYPE     DATA   AGE
secret-mysql   Opaque   1      11s
```

<br/>

```
$ kubectl -n database get secrets secret-mysql -o json | jq .data.password -r
$ kubectl -n database get secrets secret-mysql -o json | jq .data.password -r | base64 -d
mysql-password-0123456789
```

<br/>

```
// OK!
http://192.168.49.2:30008/
```
