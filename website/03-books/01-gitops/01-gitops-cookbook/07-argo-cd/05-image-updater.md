---
layout: page
title: GitOps Cookbook - Argo CD - Image Updater
description: С помощью Argo CD деплоить новый контейнер как он появится в registry
keywords: books, gitops, argo-cd, Image Updater
permalink: /books/gitops/gitops-cookbook/argo-cd/image-updater/
---

<br/>

# [Book] [OK!] 7.5 Image Updater

<br/>

**Задача:**  
С помощью Argo CD обновлять tag в манифестах, как только в registry появится новая версия

<br/>

**Делаю:**  
2025.12.04

<br/>

### Подготовительные шаги

**1. Создать токен для работы с repo**

https://github.com/settings/tokens

<br/>

Или можно кликать по иконкам:

**GithubUserName -> Settings -> Developer Settings -> Personal access token -> Tokens (classic) ->**

<br/>

**Genereate new token (classic) -> ARGO_TOKEN**

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: github-secret
  namespace: argocd
  annotations:
    tekton.dev/git-0: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: YOUR_USERNAME
  password: YOUR_PASSWORD
EOF
```

<br/>

```
YOUR_USERNAME - github username
YOUR_PASSWORD - GitHub personal access token
```

<br/>

**2. Развернуть приложение**

<!-- <br/>

```
$ kubectl --namespace argocd create secret generic git-creds \
    --from-literal=username=<YOUR_GITHUB_USERNAME> \
    --from-literal=password=<YOUR_GITHUB_TOKEN>
``` -->

<br/>

Из-за блокировок на скачивание с quay.io, перекладываю image к себе в бесплатных облаках [google-cloud-shell](/tools/clouds/google/google-cloud-shell/setup/).

<br/>

```
$ docker pull quay.io/rhdevelopers/bgd
```

<br/>

```
$ docker login -u webmakaka
$ docker tag quay.io/rhdevelopers/bgd webmakaka/bgd:1.0.0
$ docker push webmakaka/bgd:1.0.0
```

<br/>

```
gitops-cookbook-sc/ch07/bgdui/base/bgd-deployment.yaml
```

<br/>

```yaml
containers:
  - image: webmakaka/bgd:1.0.0
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bgdk-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/wildmakaka/gitops-cookbook-sc.git
    targetRevision: main
    path: ch07/bgdui/bgdk
  destination:
    server: https://kubernetes.default.svc
    namespace: bgdk
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
      allowEmpty: true
EOF
```

<br/>

```
$ argocd app sync bgdk-app
```

<br/>

### (Можно пропустить) Посмотреть на задеплоенное приложение

<br/>

```
$ kubectl patch svc bgd -n bgdk -p '{"spec": {"type": "NodePort"}}'
```

<br/>

```
$ kubectl get services -n bgdk
NAME   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
bgd    NodePort   10.100.62.50   <none>        8080:32538/TCP   3m21s
```

<br/>

```
$ MINIKUBE_IP=$(minikube --profile ${PROFILE} ip)
$ echo $MINIKUBE_IP
```

<br/>

```
$ APP_NODE_PORT=$(kubectl get svc bgd -n bgdk -o jsonpath='{.spec.ports[?(@.port==8080)].nodePort}')
```

<br/>

```
// [OK!]
$ echo http://$MINIKUBE_IP:$APP_NODE_PORT
```

<br/>

### [Устанавливаю argocd-image-updater](/tools/gitops/ci-cd/argo/argo-image-updater/setup/)

<br/>

### Запуск примера

<br/>

// Выполнение следующего манифеста должно прописать в файл gitops-cookbook-sc/ch07/bgdui/bgdk/.argocd-source-bgdk-app.yaml webmakaka/bgd:18.0.0

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: argocd-image-updater.argoproj.io/v1alpha1
kind: ImageUpdater
metadata:
  name: bgdk-image-updater
  namespace: argocd
spec:
  namespace: argocd
  writeBackConfig:
    method: git:secret:argocd/github-secret
    gitConfig:
      repository: https://github.com/wildmakaka/gitops-cookbook-sc.git
      branch: main
  applicationRefs:
    - namePattern: bgdk-app
      images:
        - alias: bgd
          imageName: webmakaka/bgd:18.0.0
EOF
```

<br/>

// Выполнение следующего манифеста должно прописать в файл gitops-cookbook-sc/ch07/bgdui/bgdk/.argocd-source-bgdk-app.yaml версию, которая появилась в registry

<br/>

```
$ docker tag quay.io/rhdevelopers/bgd webmakaka/bgd:20.0.0
$ docker push webmakaka/bgd:20.0.0
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: argocd-image-updater.argoproj.io/v1alpha1
kind: ImageUpdater
metadata:
  name: bgdk-image-updater
  namespace: argocd
spec:
  namespace: argocd
  commonUpdateSettings:
    updateStrategy: semver
  writeBackConfig:
    method: git:secret:argocd/github-secret
    gitConfig:
      repository: https://github.com/wildmakaka/gitops-cookbook-sc.git
      branch: main
  applicationRefs:
    - namePattern: bgdk-app
      images:
        - alias: bgd
          imageName: webmakaka/bgd
EOF
```

<br/>

В результате в репо версия обновилась. Спустя 2 минут и на сервер приехала обновленна версия image.

<br/>

# Проверим созданные ресурсы

```
$ kubectl get secret github-secret -n argocd
$ kubectl get application bgdk-app -n argocd
$ kubectl get imageupdater bgdk-image-updater -n argocd
```

<br/>

```
// Получить логи
$ POD_NAME=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-image-updater -o name)
$ kubectl logs -n argocd $POD_NAME --tail=20
```
