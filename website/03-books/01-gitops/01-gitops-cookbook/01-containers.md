---
layout: page
title: GitOps Cookbook - Building a Container Using Shipwright and kaniko in Kubernetes
description: GitOps Cookbook - Building a Container Using Shipwright and kaniko in Kubernetes
keywords: GitOps Cookbook, Building a Container Using Shipwright and kaniko in Kubernetes
permalink: /books/gitops/gitops-cookbook/containers/
---

<br/>

# [Book] GitOps Cookbook: 03. Containers

<br/>

## 03.5 - Building a Container Using Shipwright and kaniko in Kubernetes

<br/>

**Делаю:**  
25.05.2023

<br/>

[Поставил Tekton](//docs.k8s.ru/tools/containers/kubernetes/utils/ci-cd/tekton/)

<br/>

```
$ kubectl apply -f \
    https://github.com/shipwright-io/build/releases/download/v0.11.0/release.yaml
```

<br/>

```
$ kubectl get pods -n shipwright-build
NAME                                          READY   STATUS    RESTARTS   AGE
shipwright-build-controller-86547f98d-4wz8b   1/1     Running   0          59s
```

<br/>

```
$ kubectl apply -f \
    https://github.com/shipwright-io/build/releases/download/v0.11.0/sample-strategies.yaml
```

<br/>

```
$ kubectl get cbs
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

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: shipwright.io/v1alpha1
kind: Build
metadata:
  name: kaniko-nodejs-build
spec:
  source:
    url: https://github.com/shipwright-io/sample-nodejs
    contextDir: docker-build
  strategy:
    name: kaniko
    kind: ClusterBuildStrategy
  output:
    image: webmakaka/sample-nodejs:latest
    credentials:
      name: push-secret
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
apiVersion: shipwright.io/v1alpha1
kind: BuildRun
metadata:
  generateName: kaniko-nodejs-buildrun-
spec:
  buildRef:
    name: kaniko-nodejs-build
EOF
```

<br/>

```
NAME                                     READY   STATUS      RESTARTS   AGE
kaniko-nodejs-buildrun-qj8wh-7xk8s-pod   0/3     Completed   0          2m23s
```

<br/>

```
$ kubectl logs -f kaniko-nodejs-buildrun-qgnct-nw46r-pod -c step-build-and-push
```

<br/>

```
$ kubectl get buildruns
NAME                           SUCCEEDED   REASON   STARTTIME   COMPLETIONTIME
kaniko-nodejs-buildrun-qj8wh   True        Succeeded   22m         20m
```
