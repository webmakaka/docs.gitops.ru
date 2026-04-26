---
layout: page
title: GitOps Cookbook - Advanced Topics - Encrypt Sensitive Data (Sealed Secrets)
description: Зашифровать Secret в Git
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Encrypt Sensitive Data (Sealed Secrets)
permalink: /books/gitops/gitops-cookbook/advanced-topics/sealed-secrets/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 08. Advanced Topics: 8.1 Encrypt Sensitive Data (Sealed Secrets)

<br/>

**Задача:**  
Зашифровать Secret в Git

<br/>

**Делаю:**  
2025.12.04

<br/>

### [Установка kubeseal и контроллера](//docs.k8s.ru/tools/containers/kubernetes/utils/security/bitnami-seal/)

<br/>

```shell
$ kubectl create secret generic pacman-secret \
    --from-literal=user=pacman \
    --from-literal=pass=pacman
```

<br/>

```shell
$ kubectl get secret pacman-secret -o yaml
```

```shell
$ kubectl get secret pacman-secret -o yaml \
  | kubeseal -o yaml > pacman-sealedsecret.yaml
```

<br/>

```shell
$ cat pacman-sealedsecret.yaml
```

<br/>

Отправляю его в репо:

<br/>

```shell
$ kubectl delete secret pacman-secret -n default -o yaml
```

<br/>

```shell
$ argocd app create pacman \
--repo https://github.com/wildmakaka/pacman-kikd-manifests.git \
--path 'k8s/sealedsecrets' \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--sync-policy auto
```

<br/>

```shell
$ argocd app list
```

<br/>

```shell
$ argocd app sync pacman
```

<br/>

Пароли лежат в репо в зашифрованном виде, а на сервере в расшифрованном.

<br/>

```shell
$ argocd app delete pacman
```
