---
layout: page
title: Supercharge your Kubernetes deployments with Flux v2 and GitHub
description: Supercharge your Kubernetes deployments with Flux v2 and GitHub
keywords: linux, kubernetes, FluxCD, Kustomize
permalink: /courses/gitops/ci-cd/fluxcd/supercharge-your-kubernetes-deployments-with-flux-v2-and-github/
---

# Supercharge your Kubernetes deployments with Flux v2 and GitHub

<br/>

Делаю:  
06.11.2021

<br/>

https://www.youtube.com/watch?v=N6UCKF7JD7k&list=PLG9qZAczREKmCq6on_LG8D0uiHMx1h3yn&index=1

<br/>

У нас есть 2 репо и мы создаем спец.репо flux-infra, которое работает с k8s.

<br/>

**Форкаем себе подготовленное репо 1:**  
https://github.com/gbaeke/realtimeapp

<br/>

**Кликнуть - Разрешить работать с Actions**
https://github.com/${GITHUB_USER}/realtimeapp/actions

Это само приложение, которое деплоится на сервер.

По хорошему, нужно настроить, чтобы собиралось и отправлялось в личный registry.

<br/>

**Форкаем себе подготовленное репо с конфигами, которые используются для деплоя:**  
https://github.com/gbaeke/realtimeapp-infra

<br/>

3-е репо служебное flux-infra. В нем описано за изменениями в каких репо следует следить.

<br/>

По идее:

- в случае релиза realtimeapp. Создаются новые образы и закидываются в личный registry
- обновляется версия image в репо с конфигами realtimeapp-infra
- обновляется версия приложения в кластере.

<br/>

## 01-Supercharge your Kubernetes deployments with Flux v2 and GitHub - Introduction

<br/>

### [Используется беслпатное облако Google](/tools/clouds/google/google-cloud-shell/setup/)

<br/>

1. Инсталляция [MiniKube](//docs.k8s.ru/tools/containers/kubernetes/minikube/setup/)

**Испольновалась версия KUBERNETES_VERSION=v1.22.2**

2. Инсталляция [Kubectl](//docs.k8s.ru/tools/containers/kubernetes/utils/kubectl/)

3. Инсталляция fluxcd

<br/>

```
// Инсталляция fluxcd
$ curl -s https://fluxcd.io/install.sh | sudo bash
```

<br/>

```
$ flux --version
flux version 0.21.1
```

<br/>

```
$ flux install
```

<br/>

```
$ flux check
► checking prerequisites
✔ Kubernetes 1.22.2 >=1.19.0-0
► checking controllers
✔ helm-controller: deployment ready
► ghcr.io/fluxcd/helm-controller:v0.12.1
✔ kustomize-controller: deployment ready
► ghcr.io/fluxcd/kustomize-controller:v0.16.0
✔ notification-controller: deployment ready
► ghcr.io/fluxcd/notification-controller:v0.18.1
✔ source-controller: deployment ready
► ghcr.io/fluxcd/source-controller:v0.17.2
✔ all checks passed
```

<br/>

4. [Инсталляция gh Linux и настройка работы с GitHub по SSH ключу](/github/setup/)

<br/>

5. Инсталляция kustomize

```
$ curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && chmod +x kustomize && sudo mv kustomize /usr/local/bin/

$ kustomize version
Version:kustomize/v4.4.0
```

<br/>

```
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)

$ echo ${INGRESS_HOST}

$ export GITHUB_USER=<YOUR_GITHUB_USERNAME>

$ export GITHUB_TOKEN=<YOUR_GITHUB_TOKEN>
```

<br/>

```
$ cd ~
// Будет создано приватное репо flux-infra
$ flux bootstrap github \
    --owner=${GITHUB_USER} \
    --repository=flux-infra \
    --branch=master \
    --path=app-cluster \
    --personal
```

<br/>

## 02-Kubernetes deployments with Flux v2 introduction to kustomize (Пропустить! Материал просто для знакомства с kustomize)

<br/>

```
$ mkdir -p ~/tmp && cd ~/tmp

$ git clone https://github.com/gbaeke/realtimeapp-infra

$ cd realtimeapp-infra/deploy/overlays/dev
$ kustomize build

// Сразу еще и применить
// $ kustomize build | kubeclt apply -f -
```

<br/>

## 03-Kubernetes deployments with Flux v2 Deploying Manifests

<br/>

Автор сначала рассказывает до 12 минуты, потом показывает как делать!

<br/>

```
$ git clone git@github.com:${GITHUB_USER}/flux-infra.git
$ git checkout master
$ cd flux-infra
```

<br/>

```
$ flux create source git realtimeapp-infra \
    --url https://github.com/${GITHUB_USER}/realtimeapp-infra \
    --branch master \
    --interval 30s \
    --export > ./app-cluster/realtimeapp-source.yaml
```

<br/>

```
$ flux create kustomization realtimeapp-dev \
    --source realtimeapp-infra \
    --path "./deploy/overlays/dev" \
    --prune true \
    --interval 1m \
    --health-check="Deployment/realtime-dev.realtime-dev" \
    --health-check="Deployment/redis-dev.realtime-dev" \
    --health-check-timeout=2m \
    --export > ./app-cluster/realtimeapp-dev.yaml
```

<br/>

```
$ flux create kustomization realtimeapp-prd \
    --source realtimeapp-infra \
    --path "./deploy/overlays/prd" \
    --prune true \
    --interval 1m \
    --health-check="Deployment/realtime-prd.realtime-prd" \
    --health-check="Deployment/redis-prd.realtime-prd" \
    --health-check-timeout=2m \
    --export > ./app-cluster/realtimeapp-prd.yaml
```

<br/>

```
$ cat ./app-cluster/realtimeapp-source.yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: realtimeapp-infra
  namespace: flux-system
spec:
  interval: 30s
  ref:
    branch: master
  url: https://github.com/wildmakaka/realtimeapp-infra
```

<br/>

```
$ cat ./app-cluster/realtimeapp-dev.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: realtimeapp-dev
  namespace: flux-system
spec:
  healthChecks:
  - kind: Deployment
    name: realtime-dev
    namespace: realtime-dev
  - kind: Deployment
    name: redis-dev
    namespace: realtime-dev
  interval: 1m0s
  path: ./deploy/overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: realtimeapp-infra
  timeout: 2m0s
```

<br/>

```
$ cat ./app-cluster/realtimeapp-prd.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: realtimeapp-prd
  namespace: flux-system
spec:
  healthChecks:
  - kind: Deployment
    name: realtime-prd
    namespace: realtime-prd
  - kind: Deployment
    name: redis-prd
    namespace: realtime-prd
  interval: 1m0s
  path: ./deploy/overlays/prd
  prune: true
  sourceRef:
    kind: GitRepository
    name: realtimeapp-infra
  timeout: 2m0s
```

<br/>

```
$ kubectl get ns
NAME              STATUS   AGE
default           Active   28m
flux-system       Active   16m
ingress-nginx     Active   28m
kube-node-lease   Active   28m
kube-public       Active   28m
kube-system       Active   28m
```

<br/>

```
$ git add --all

$ git commit -m "Added source and kustomization"

$ git push --set-upstream origin master
```

<br/>

```
$ flux get kustomizations
NAME           	READY	MESSAGE                                                          	REVISION                                       	SUSPENDED
flux-system    	True 	Applied revision: master/4d351c32ab089c8644671bc7627f9574fd412727	master/4d351c32ab089c8644671bc7627f9574fd412727	False
realtimeapp-dev	True 	Applied revision: master/401ddd880d59f2dc0a65402bedfa6e1b4099666e	master/401ddd880d59f2dc0a65402bedfa6e1b4099666e	False
realtimeapp-prd	True 	Applied revision: master/401ddd880d59f2dc0a65402bedfa6e1b4099666e	master/401ddd880d59f2dc0a65402bedfa6e1b4099666e	False
```

<br/>

Нужно дождаться, чтобы появились realtimeapp-dev и realtimeapp-prd с состоянием READY - True

<br/>

```
$ kubectl get ns
NAME              STATUS   AGE
default           Active   6d9h
flux-system       Active   18m
kube-node-lease   Active   6d9h
kube-public       Active   6d9h
kube-system       Active   6d9h
realtime-dev      Active   82s
realtime-prd      Active   83s
```

<br/>

```
$ kubectl get pods -n realtime-dev
NAME                            READY   STATUS    RESTARTS      AGE
realtime-dev-5d86fb7b78-df672   1/1     Running   1 (47s ago)   61s
redis-dev-589977c5c6-m5ft5      1/1     Running   0             61s
```

<br/>

```
$ kubectl get pods -n realtime-prd
NAME                            READY   STATUS    RESTARTS   AGE
realtime-prd-576b496476-2sf6m   1/1     Running   0          34s
realtime-prd-576b496476-8cxcg   1/1     Running   0          34s
realtime-prd-576b496476-dd4f5   1/1     Running   0          34s
redis-prd-589977c5c6-65ch8      1/1     Running   0          34s
```

<br/>

```
// Дать пинка, чтобы обновилось
$ flux reconcile kustomization realtimeapp-dev
```

<br/>

### Создание нового релиза

<br/>

```
$ kubectl -n realtime-prd describe pod realtime-prd-576b496476-2sf6m | grep Image:
    Image:          gbaeke/flux-rt:1.0.2
```

<br/>

**По идее:**

https://github.com/${GITHUB_USER}/realtimeapp/

New Release

1.0.3

Publish

В Actions должен пойти билд.

<br/>

Должен сработать kustomize edit который поменяет версию.

https://github.com/wildmakaka/realtimeapp-infra/blob/master/deploy/overlays/prd/kustomization.yaml

Но я поменяю ее руками. На 1.0.1 т.к. 1.0.3 просто нет в репо автора.

<br/>

```
$ kubectl -n realtime-prd describe pod realtime-prd-566d96bc7f-4xg8n | grep Image:
    Image:          gbaeke/flux-rt:1.0.1
```

<br/>

## 04-Kubernetes deployments with Flux v2 Monitoring and Alerting

<br/>

(Пропустил этот шаг)

<br/>

```
$ cd ~/project/dev/flux-infra
```

<br/>

```
$ flux create source git monitoring \
    --url https://github.com/fluxcd/flux2 \
    --branch master \
    --interval 30m \
    --export > ./app-cluster/monitor-source.yaml
```

<br/>

```
$ flux create kustomization monitoring \
    --source monitoring \
    --path "./manifests/monitoring" \
    --prune true \
    --interval 1h \
    --health-check="Deployment/prometheus.flux-system" \
    --health-check="Deployment/grafana.flux-system" \
    --export > ./app-cluster/monitor-kustomization.yaml
```

<br/>

commit, push

<br/>

```
$ watch flux get kustomizations
```

<br/>

```
$ kubectl -n flux-system port-forward svc/grafana 3000:3000
```

<br/>

Далее Alerting, какие-то teams и т.д. Наверное, имеет смысл пересмотреть.

<br/>

```
$ flux get alert-providers
```

<br/>

## 05-Kubernetes Deployments with Flux v2 Helm Basics

<br/>

В этом уроке используются HELM репозитории. Bitnami для redis и автора для его проекта (кстати он им не поделился или я не нашел!).

<br/>

```
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install redis --set cluster.enabled=false,usePassword=false bitnami/redis
```

<br/>

```
// Нет репо
$ helm install realtimeapp --wait .
```

<br/>

```
$ helm uninstall realtimeapp
$ helm uninstall redis
```

<br/>

### Повторяем с использованием flux

<br/>

```
$ flux create source helm bitnami \
    --url https://charts.bitnami.com/bitnami \
    --interval 1m0s \
    --export > ./app-cluster/helmrepo-bitnami.yaml
```

<br/>

```
$ flux get sources helm
```

<br/>

```
$ flux create helmrelease redis \
    --source=HelmRepository/bitnami \
    --chart redis \
    --release-name redis \
    --target-namespace default \
    --interval 5m0s \
    --export > ./app-cluster/helmrelease-redis.yaml
```

<br/>

```
$ flux get sources helm
```

<br/>

```
$ export HELM_EXPERIMENTAL_OCI=1
$ helm chart save . realtimeapp:1.0.2

// Отправляем в helm registry
$ helm chart save . gebareg.azurecr.io/realtimeapp:1.0.2
$ helm registry login gebareg.azurecr.io
$ helm chart push gebareg.azurecr.io/realtimeapp:1.0.2

// Защищенный паролем репо
$ kubectl create secret generic acr --from-literal username=gebareg --from-literal "password=THEPASSWORD" -n flux-system
```

<br/>

```
$ flux create source helm realtimeapp \
    --url https://gebareg.auzrecr.io/helm/v1/repo/ \
    --interval 1m0s \
    --secret-ref acr \
    --export > ./app-cluster/helmrepo-realtimeapp.yaml
```

<br/>

```
$ flux create helmrelease realtimeapp \
    --source=HelmRepository/realtimeapp \
    --chart realtimeapp \
    --release-name realtimeapp \
    --target-namespace default \
    --interval 5m0s \
    --export > ./app-cluster/helmrelease-realtimeapp.yaml
```

<br/>

Добавили некоторые изменения в конфиги редиса и realtimeapp.
