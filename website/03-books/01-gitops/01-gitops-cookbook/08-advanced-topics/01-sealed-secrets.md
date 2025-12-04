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

```
$ kubectl create secret generic pacman-secret \
    --from-literal=user=pacman \
    --from-literal=pass=pacman
```

<br/>

```
$ kubectl get secret pacman-secret -o yaml
```

```
$ kubectl get secret pacman-secret -o yaml \
  | kubeseal -o yaml > pacman-sealedsecret.yaml
```

<br/>

```
$ cat pacman-sealedsecret.yaml
```

<br/>

Отправляю его в репо:

<br/>

```
$ kubectl delete secret pacman-secret -n default -o yaml
```

<br/>

```
$ argocd app create pacman \
--repo https://github.com/wildmakaka/pacman-kikd-manifests.git \
--path 'k8s/sealedsecrets' \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--sync-policy auto
```

<br/>

```
$ argocd app list
```

<br/>

```
$ argocd app sync pacman
```

<br/>

Пароли лежат в репо в зашифрованном виде, а на сервере в расшифрованном.

<br/>

```
$ argocd app delete pacman
```
