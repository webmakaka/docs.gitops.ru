---
layout: page
title: Инсталляция ArgoCD на Minikube
description: Инсталляция ArgoCD на Minikube
keywords: devops, containers, kubernetes, ci-cd, argocd, setup, minikube
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argocd/setup/
---

# Инсталляция ArgoCD на Minikube

<br/>

Делаю:  
2025.03.02

<br/>

https://argo-cd.readthedocs.io/en/stable/getting_started/

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

### Подключиться в консоли

<br/>

### [Install Argo CD CLI](/tools/containers/kubernetes/utils/ci-cd/argo/argocd/setup/cli/)

<br/>

```
$ kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

<br/>

```
$ kubectl get svc -n argocd
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP   10.97.206.224    <none>        7000/TCP,8080/TCP            26m
argocd-dex-server                         ClusterIP   10.104.246.7     <none>        5556/TCP,5557/TCP,5558/TCP   26m
argocd-metrics                            ClusterIP   10.97.72.90      <none>        8082/TCP                     26m
argocd-notifications-controller-metrics   ClusterIP   10.105.22.117    <none>        9001/TCP                     26m
argocd-redis                              ClusterIP   10.104.174.108   <none>        6379/TCP                     26m
argocd-repo-server                        ClusterIP   10.98.29.178     <none>        8081/TCP,8084/TCP            26m
argocd-server                             NodePort    10.109.5.199     <none>        80:32763/TCP,443:31778/TCP   26m
argocd-server-metrics                     ClusterIP   10.110.183.112   <none>        8083/TCP                     26m
```

<br/>

```
$ export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
$ echo ${ARGOCD_PASSWORD}
```

<br/>

```
$ minikube --profile ${PROFILE} ip
192.168.49.2
```

<br/>

```
$ argocd login --insecure --grpc-web 192.168.49.2:32763 --username admin \
    --password ${ARGOCD_PASSWORD}

***
'admin:login' logged in successfully
Context '192.168.49.2:32763' updated
```

<br/>

```
$ argocd version
argocd: v2.14.3+71fd4e5
  BuildDate: 2025-02-28T19:21:52Z
  GitCommit: 71fd4e501d0d688ab0d70cd649fbf5f909cff12b
  GitTreeState: clean
  GoVersion: go1.23.3
  Compiler: gc
  Platform: linux/amd64
argocd-server: v2.14.3+71fd4e5
  BuildDate: 2025-02-28T18:56:13Z
  GitCommit: 71fd4e501d0d688ab0d70cd649fbf5f909cff12b
  GitTreeState: clean
  GoVersion: go1.23.3
  Compiler: gc
  Platform: linux/amd64
  Kustomize Version: v5.4.3 2024-07-19T16:40:33Z
  Helm Version: v3.16.3+gcfd0749
  Kubectl Version: v0.31.0
  Jsonnet Version: v0.20.0
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
