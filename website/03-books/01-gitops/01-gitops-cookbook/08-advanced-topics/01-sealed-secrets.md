---
layout: page
title: GitOps Cookbook - Advanced Topics - Encrypt Sensitive Data (Sealed Secrets)
description: GitOps Cookbook - Advanced Topics - Encrypt Sensitive Data (Sealed Secrets)
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Encrypt Sensitive Data (Sealed Secrets)
permalink: /books/gitops/gitops-cookbook/advanced-topics/sealed-secrets/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 08. Advanced Topics: 8.1 Encrypt Sensitive Data (Sealed Secrets)

<br/>

Делаю:  
2024.05.04

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

Далее в книге обычный запуск для примера.
Не пробовал. Поленился.

```
$ argocd app create pacman \
--repo https://github.com/gitops-cookbook/pacman-kikd-manifests.git \
--path 'k8s/sealedsecrets' \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--sync-policy auto
```

<br/>

```
$ argocd app list
```
