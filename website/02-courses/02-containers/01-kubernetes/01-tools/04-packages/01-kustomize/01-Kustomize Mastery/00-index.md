---
layout: page
title: Kustomize Mastery
description: Kustomize Mastery
keywords: linux, Kustomize, packages, Kustomize Mastery
permalink: /courses/containers/kubernetes/packages/kustomize/kustomize-mastery/
---

# [[Video Course][George Alonge] Kustomize Mastery: Manage Kubernetes Configuration with Ease [ENG, 2023][~4h 30m]]()

https://github.com/galonge/udemy-kustomize-mastery

<br/>

## 01. Welcome - Quick Start!

<br/>

### 04. Kustomize Hands-on - Live

<br/>

```
$ mkdir ~/projects/dev/kustomize
$ cd ~/projects/dev/kustomize
```

<br/>

```
$ git clone git@github.com:galonge/udemy-kustomize-mastery.git
$ cd udemy-kustomize-mastery/code-samples/intro/wordpress-example/
```

<br/>

```
$ kubectl apply -f manifests/v1/
```

<br/>

```
$ kubectl get pods -w
NAME                         READY   STATUS    RESTARTS   AGE
wordpress-64f98659c5-zqcvk   1/1     Running   0          44s
```

<br/>

```
$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
***
wordpress    LoadBalancer   10.100.186.38   <pending>     80:30100/TCP   28s
```

<br/>

```
$ kubectl port-forward svc/wordpress --address 0.0.0.0 8080:80
```

<br/>

```
http://localhost:8080/
```

<br/>

```
$ kubectl delete -f manifests/v1/
```

<br/>

```
$ kubectl create ns v1
$ kubectl kustomize kustomize/base/
$ kubectl apply -k kustomize/base/ -n v1
```

<br/>

```
$ kubectl kustomize kustomize/v2
$ kubectl create ns v2
$ kubectl apply -k kustomize/base/ -n v2
```

<br/>

```
$ kubectl kustomize kustomize/v3
$ kubectl create ns v3
$ kubectl apply -k kustomize/base/ -n v3
```

<br/>

## 03. The Kustomization File

<br/>

### 03. Transformers

<br/>

```
$ cd ~/projects/dev/kustomize
$ cd udemy-kustomize-mastery/code-samples/3-the-kfile/wordpress/kustomize/
$ cd v1/
// $ kustomize build . > results.yaml
$ kubectl apply -k .
```

<br/>

```
$ cd ~/projects/dev/kustomize
$ cd udemy-kustomize-mastery/code-samples/3-the-kfile/wordpress/kustomize/
$ cd v1/
// $ kustomize build . > results.yaml
$ kubectl apply -k .
```

<br/>

```
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
v1-wordpress-df6cdb988-4mvwm   1/1     Running   0          67s
```

<br/>

```
$ kubectl get svc
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        18h
v1-wordpress   NodePort    10.104.207.108   <none>        80:30001/TCP   95s
```

<br/>

### 04. Generators

<br/>

### 05. ConfigMap Generators

<br/>

```
$ cd ~/projects/dev/kustomize
$ cd udemy-kustomize-mastery/code-samples/3-the-kfile/wordpress/kustomize/lec-12-configmaps/
```

<br/>

```
$ kubectl create ns lec-12

$ kubectl config set-context --current --namespace=lec-12

$ kustomize build
$ kubectl kustomize .

$ kubectl apply -k .

$ kubectl get svc/lec-12-mysql --output="jsonpath={.spec.clusterIP}"
```

<br/>

```
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
lec-12-mysql-6d759c4c64-v2jrm       1/1     Running   0          42s
lec-12-wordpress-555c959855-d8xpp   1/1     Running   0          9m5s
```

<br/>

```
$ kubectl get cm
NAME                  DATA   AGE
kube-root-ca.crt      1      14m
lec-12-mysql-config   2      11m
```

<br/>

Если не нужно, чтобы генерился hash

```yaml
generatorOptions:
  disableNameSuffixHash: true
  labels:
    generated: 'true'
```

<br/>

// Nginx с конфигами собираем

```
$ cd from-file/
$ kustomize build
$ kubectl kustomize .

$ kubectl apply -k .
$ kubectl port-forward deploy/lec-12-nginx-deployment 30002:80
```

<br/>

```
// OK!
http://localhost:30002/
```

<br/>

```
$ kubectl delete -k .
```

<br/>

### 06. Secret Generator

<br/>

```
$ cd ~/projects/dev/kustomize
$ cd udemy-kustomize-mastery/code-samples/3-the-kfile/wordpress/kustomize/lec-13-secrets/
```

<br/>

```
$ kubectl create ns lec-13

$ kubectl config set-context --current --namespace=lec-13

$ kustomize build
$ kubectl kustomize .

$ kubectl apply -k .

$ kubectl get svc/lec-13-mysql --output="jsonpath={.spec.clusterIP}"
```

<br/>

```
$ kubectl get secret
```

<br/>

### 07. Resources

Продемонстрировли возможность указать путь к ресурсам на github

```
$ cd ../lec-14-resources/
```

<br/>

### 09. Namespaces

Неймспейсы можно задавать и создавать.  
Если не заданы, назначать.

```
$ cd ../lec-15-namespaces/
```

<br/>

### 10. Labels & Annotations

```
$ cd ../lec-16-labels-and-annotations/
```

<br/>

## 04. Working with Patches

<br/>

### 01. Patches Overview

<br/>

### 02. Patches - Strategic Merge

```
$ cd 4-patches/wordpress/kustomize/lec-18-strategic-merge
$ kustomize build .
```

<br/>

### 03. Patches - JSON6902

```
$ cd ../lec-19-json-6902/
$ kustomize build .
```

<br/>

## 05. Working with Custom Resource Definitions - CRDs

```
$ cd udemy-kustomize-mastery/code-samples/5-crds/wordpress/kustomize/lec-20-crds
```

<br/>

```
kubectl api-resources | grep apps
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
```

<br/>

```
$ kustomize build .
```

<br/>

## 06. Managing Multiple Environments with Overlays

```
$ cd udemy-kustomize-mastery/code-samples/6-multiple-envs/base
```

<br/>

```
$ kubectl apply -k .
```

<br/>

```
$ kubectl get svc,pod -o wide
```

<br/>

```
$ kubectl port-forward svc/frontend-external 30219:80
```

```
// OK!
http://localhost:30219/
```

<br/>

```
$ kubectl delete -k .
```

<br/>

```
$ cd ../day1/dev/
```

<br/>

```
$ kubectl apply -k .
```

<br/>

```
$ kubectl delete -k .
```

<br/>

```
$ cd ../stage/
$ kubectl apply -k .
```

<br/>

```
$ kubectl delete -k .
```
