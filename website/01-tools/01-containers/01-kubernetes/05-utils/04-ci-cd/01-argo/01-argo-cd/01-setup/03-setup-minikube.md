---
layout: page
title: Инсталляция ArgoCD на Minikube
description: Инсталляция ArgoCD на Minikube
keywords: devops, containers, kubernetes, ci-cd, argocd, setup, minikube
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argo-cd/setup/minikube/
---

# Инсталляция ArgoCD на Minikube

<br/>

Делаю:  
2025.12.04

<br/>

https://argo-cd.readthedocs.io/en/stable/getting_started/

<br/>

### [Установить Argo CD CLI](/tools/containers/kubernetes/utils/ci-cd/argo/argo-cd/setup/minikube/cli/)

<br/>

```
$ kubectl create namespace argocd
$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

<br/>

```
$ kubectl -n argocd get pods
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          74s
argocd-applicationset-controller-5478c64d7c-2pbqd   1/1     Running   0          74s
argocd-dex-server-6b576d67c9-z5qqh                  1/1     Running   0          74s
argocd-notifications-controller-5f6c747849-9l5sw    1/1     Running   0          74s
argocd-redis-76748db5f4-w4rjg                       1/1     Running   0          74s
argocd-repo-server-58c78bd74f-228dm                 1/1     Running   0          74s
argocd-server-5fd847d6bc-28frv                      1/1     Running   0          74s
```

<br/>

```
$ kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

<br/>

```
$ kubectl get svc -n argocd
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP   10.99.83.81      <none>        7000/TCP,8080/TCP            7m55s
argocd-dex-server                         ClusterIP   10.103.192.143   <none>        5556/TCP,5557/TCP,5558/TCP   7m55s
argocd-metrics                            ClusterIP   10.104.108.121   <none>        8082/TCP                     7m55s
argocd-notifications-controller-metrics   ClusterIP   10.106.179.252   <none>        9001/TCP                     7m55s
argocd-redis                              ClusterIP   10.101.126.79    <none>        6379/TCP                     7m55s
argocd-repo-server                        ClusterIP   10.100.42.60     <none>        8081/TCP,8084/TCP            7m55s
argocd-server                             NodePort    10.101.177.219   <none>        80:30495/TCP,443:32729/TCP   7m55s
argocd-server-metrics                     ClusterIP   10.103.94.201    <none>        8083/TCP                     7m55s
```

<br/>

```
$ export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
$ echo ${ARGOCD_PASSWORD}
```

<br/>

```
$ MINIKUBE_IP=$(minikube --profile ${PROFILE} ip)
$ echo $MINIKUBE_IP
```

<br/>

```
$ ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
```

<br/>

```
$ argocd login --insecure --grpc-web $MINIKUBE_IP:$ARGOCD_PORT --username admin \
    --password ${ARGOCD_PASSWORD}

***
'admin:login' logged in successfully
Context '192.168.49.2:32763' updated
```

<br/>

```
$ argocd version
argocd: v3.2.1+8c4ab63
  BuildDate: 2025-11-30T12:12:42Z
  GitCommit: 8c4ab63a9c72b31d96c6360514cda6254e7e6629
  GitTreeState: clean
  GoVersion: go1.25.0
  Compiler: gc
  Platform: linux/amd64
argocd-server: v3.2.1+8c4ab63
  BuildDate: 2025-11-30T11:48:14Z
  GitCommit: 8c4ab63a9c72b31d96c6360514cda6254e7e6629
  GitTreeState: clean
  GoVersion: go1.25.0
  Compiler: gc
  Platform: linux/amd64
  Kustomize Version: v5.7.0 2025-06-28T07:00:07Z
  Helm Version: v3.18.4+gd80839c
  Kubectl Version: v0.34.0
  Jsonnet Version: v0.21.0
```

<br/>

### Подключиться к UI

<br/>

```
// Получаем пароль для подключения к UI
$ kubectl -n argocd get secret argocd-initial-admin-secret \
          -o jsonpath="{.data.password}" | base64 -d; echo
```

<br/>

```
$ kubectl port-forward svc/argocd-server -n argocd 8080:443
```

<br/>

```
// admin / результат выполнения команды выше.
http://localhost:8080
```

<br/>

```
// swagger
https://localhost:8080/swagger-ui
```

<br/>

```
# Argocd cli command to get the argocd context
$ argocd context
```

