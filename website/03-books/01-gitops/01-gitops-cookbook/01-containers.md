---
layout: page
title: GitOps Cookbook - Building a Container Using Shipwright and Kaniko in Kubernetes
description: Вам нужно создать docker image с помощью kubernetes
keywords: GitOps Cookbook, Tekton, Shipwright, Kaniko in Kubernetes
permalink: /books/gitops/gitops-cookbook/containers/
---

<br/>

# [Book] GitOps Cookbook: 03. Containers

<br/>

## 03.5 - Building a Container Using Shipwright and Kaniko in Kubernetes

<br/>

**Делаю:**  
2025.11.25

<br/>

**Задача:**  
Вам нужно создать docker image с помощью kubernetes

<br/>

[Использовал kind](//docs.k8s.ru/tools/containers/kubernetes/kind/)

<br/>

// Shipwright Installation
https://shipwright.io/docs/getting-started/installation/

<br/>

[Поставил Tekton](/tools/containers/kubernetes/utils/ci-cd/tekton/)

<br/>

```
$ kubectl apply -f https://github.com/shipwright-io/build/releases/latest/download/release.yaml --server-side=true

$ kubectl apply -f https://github.com/shipwright-io/build/releases/latest/download/sample-strategies.yaml
```

<br/>

```
$ kubectl get cbs
NAME                              AGE
buildah-shipwright-managed-push   8s
buildah-strategy-managed-push     8s
buildkit                          8s
buildpacks-v3                     8s
buildpacks-v3-heroku              8s
kaniko                            8s
ko                                8s
multiarch-native-buildah          8s
source-to-image                   8s
source-to-image-redhat            8s

```

<br/>

```
$ kubectl get crd | grep shipwright
buildruns.shipwright.io                    2025-11-24T21:34:32Z
builds.shipwright.io                       2025-11-24T21:34:32Z
buildstrategies.shipwright.io              2025-11-24T21:34:32Z
clusterbuildstrategies.shipwright.io       2025-11-24T21:34:32Z
```

<br/>

```
$ kubectl get crd buildruns.shipwright.io
NAME                      CREATED AT
buildruns.shipwright.io   2025-11-24T21:34:32Z
```

<br/>

```
$ kubectl get pods -n shipwright-build
NAME                                           READY   STATUS              RESTARTS   AGE
shipwright-build-controller-7f44f9f94d-swk6k   1/1     Running             0          2m3s
shipwright-build-webhook-77c859b87f-7tfw2      0/1     ContainerCreating   0          2m3s
```

<br/>

```
// Подебажить, если нужно. А тут такое!
$ kubectl events -n shipwright-build
LAST SEEN               TYPE      REASON        OBJECT                                          MESSAGE
5m50s (x87 over 166m)   Warning   FailedMount   Pod/shipwright-build-webhook-77c859b87f-7tfw2   MountVolume.SetUp failed for volume "webhook-certs" : secret "shipwright-build-webhook-cert" not found
```

<br/>

```
// Создайте временный self-signed сертификат
$ openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out webhook.crt -keyout webhook.key -subj "/CN=shipwright-build-webhook.shipwright-build.svc"

// Создайте secret
$ kubectl create secret tls shipwright-build-webhook-cert -n shipwright-build --cert=webhook.crt --key=webhook.key


// Удаляем pod
$ kubectl delete pod shipwright-build-webhook-77c859b87f-7tfw2 -n shipwright-build
```

<br/>

```
// Поиск сертификата
$ kubectl get secrets -n shipwright-build | grep -E "(webhook|cert|tls)"
shipwright-build-webhook-cert   kubernetes.io/tls   2      4m58s

```

<br/>

```
$ kubectl get pods -n shipwright-build
NAME                                           READY   STATUS    RESTARTS   AGE
shipwright-build-controller-7f44f9f94d-swk6k   1/1     Running   0          173m
shipwright-build-webhook-77c859b87f-t5vzf      1/1     Running   0          3m
```

<br/>

```
$ {
    export REGISTRY_SERVER=https://index.docker.io/v1/
    export REGISTRY_USER=webmakaka
    export REGISTRY_PASSWORD=webmakaka-password
    export EMAIL=webmakaka-email@mail.ru

    echo ${REGISTRY_SERVER}
    echo ${REGISTRY_USER}
    echo ${REGISTRY_PASSWORD}
    echo ${EMAIL}
}
```

<br/>

```
// Создаем секрет с пародлями для hub.docker.com
$ kubectl create secret docker-registry push-secret \
    --docker-server=${REGISTRY_SERVER} \
    --docker-username=${REGISTRY_USER} \
    --docker-password=${REGISTRY_PASSWORD} \
    --docker-email=${EMAIL}
```

<br/>

```
$ kubectl get secrets
NAME          TYPE                             DATA   AGE
push-secret   kubernetes.io/dockerconfigjson   1      8s

```

<br/>

```
// Если нужно обновить api
$ kubectl api-resources | grep Build
```

<br/>

```
# Посмотреть схему Build для v1beta1
$ kubectl explain build.shipwright.io --api-version=shipwright.io/v1beta1

# Посмотреть специфичные поля
$ kubectl explain build.shipwright.io.spec --api-version=shipwright.io/v1beta1
$ kubectl explain build.shipwright.io.spec.source --api-version=shipwright.io/v1beta1
$ kubectl explain build.shipwright.io.spec.output --api-version=shipwright.io/v1beta1
```

<br/>

**Форкаю:**  
https://github.com/shipwright-io/sample-nodejs

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: shipwright.io/v1beta1
kind: Build
metadata:
  name: kaniko-nodejs-build
spec:
  source:
    type: Git
    git:
      url: https://github.com/wildmakaka/sample-nodejs
    contextDir: docker-build
  strategy:
    name: kaniko
    kind: ClusterBuildStrategy
  output:
    image: webmakaka/sample-nodejs:latest
    pushSecret: push-secret
EOF
```

<br/>

```
$ kubectl get builds
NAME                  REGISTERED   REASON      BUILDSTRATEGYKIND      BUILDSTRATEGYNAME   CREATIONTIME
kaniko-nodejs-build   True         Succeeded   ClusterBuildStrategy   kaniko              21s
```

<br/>

```yaml
$ cat << EOF | kubectl create -f -
apiVersion: shipwright.io/v1beta1
kind: BuildRun
metadata:
  generateName: kaniko-nodejs-buildrun-
spec:
  build:
    name: kaniko-nodejs-build
EOF
```

<br/>

```
$ kubectl get pods
NAME                                     READY   STATUS      RESTARTS   AGE
kaniko-nodejs-buildrun-hjrkn-5wstd-pod   0/3     Completed   0          2m23s
```

<br/>

```
// Дебаг
$ kubectl logs -f kaniko-nodejs-buildrun-xp5n5-2mfsx-pod -c step-source-default
$ kubectl logs -f kaniko-nodejs-buildrun-xp5n5-2mfsx-pod -c step-build-and-push
```

<br/>

```
// Ждем результат
$ kubectl get buildruns -w
NAME                           SUCCEEDED   REASON      STARTTIME   COMPLETIONTIME
kaniko-nodejs-buildrun-hjrkn   True        Succeeded   3m6s        52s
```

<br/>

**Вот здесь появился image:**

```
https://hub.docker.com/r/webmakaka/sample-nodejs
```
