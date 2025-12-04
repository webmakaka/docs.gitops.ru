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

Делаю:  
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
$ argocd app sync bgdk-app
```

<br/>

```
// [OK!]
$ echo http://$MINIKUBE_IP:$APP_NODE_PORT
```

<br/>

```
// Удаляю
gitops-cookbook-sc/ch07/bgdui/bgdk/.argocd-source-bgdk-app.yaml
```

====================================

<br/>

```
// Переименовываю
gitops-cookbook-sc/ch07/bgdui/bgdk/.argocd-source-bgdk-app.yaml

в

gitops-cookbook-sc/ch07/bgdui/bgdk/argocd-source-bgdk-app.yaml
```

<br/>

```
$ docker tag webmakaka/bgd:1.0.0 webmakaka/bgd:12.0.0
$ docker push webmakaka/bgd:1.1.0
```

<br/>

Образ обновился.  
Файл в репо сгенерился новый.

<br/>

```
$ argocd app delete bgdk-app
```

=======================

<br/>

https://github.com/argoproj-labs/argocd-image-updater

<br/>

https://argocd-image-updater.readthedocs.io/en/stable/basics/update-methods/

<br/>

```
// Устанавливаю argocd-image-updater
// Походу теперь его нужно ставит в отдельный namespace, раньше работало в namespace argocd
$ kubectl create -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml
```

=======================

<br/>

С версии v1.0.0 Image Updater перешел на использование отдельных ImageUpdater CRD, а не аннотаций в Application ресурсах.

```
$ helm repo add argo https://argoproj.github.io/argo-helm
```

<br/>

```
$ helm install argocd-image-updater argo/argocd-image-updater \
 --namespace argocd \
 --set argocd.insecure=true
```

<br/>

```
$ kubectl get crd | grep imageupdater
imageupdaters.argocd-image-updater.argoproj.io   2025-12-04T02:17:18Z
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
  writeBackConfig:
    method: git:secret:argocd/github-secret
    gitConfig:
      repository: https://github.com/wildmakaka/gitops-cookbook-sc.git
      branch: main
  applicationRefs:
    - namePattern: bgdk-app
      images:
        - alias: bgd
          imageName: webmakaka/bgd:17.0.0
          commonUpdateSettings:
            updateStrategy: semver
            # Для семантического версионирования без фильтрации по regex
            # Просто оставьте пустым или удалите allowTags
EOF
```

<br/>

# Проверим созданные ресурсы

```
$ kubectl get secret github-secret -n argocd
$ kubectl get application bgdk-app -n argocd
$ kubectl get imageupdater bgdk-image-updater -n argocd
```

======================

<br/>

```
// Получать логи
$ POD_NAME=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-image-updater -o name)
$ kubectl logs -n argocd $POD_NAME --tail=20
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bgdk-app
  namespace: argocd
  annotations:
    argocd-image-updater.argoproj.io/image-list: webmakaka/bgd
    argocd-image-updater.argoproj.io/write-back-method: git:secret:argocd/github-secret
    argocd-image-updater.argoproj.io/git-branch: main
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
