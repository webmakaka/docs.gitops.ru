---
layout: page
title: Minio
description: Minio
keywords: gitops, containers, Minio
permalink: /tools/containers/kubernetes/utils/minio/
---

# Minio для теста

<br/>

**Делаю:**  
2026.03.26

<br/>

[Metal LB установлен!](//docs.k8s.ru/tools/containers/kubernetes/utils/metal-lb/minikube/setup/addon/)

<br/>

### Устанавливаем Minio

<br/>

```
$ helm repo add minio https://charts.min.io/
$ helm repo update
```

<br/>

```
// Последняя версия chart
// 5.4.0
$ helm search repo minio
```

<br/>

```
// $ helm uninstall minio minio/minio -n minio

// Устанавливаем Minio
$ helm install minio minio/minio \
  --namespace minio --create-namespace \
  --set mode=standalone \
  --set replicas=1 \
  --set resources.requests.memory=256Mi \
  --set resources.limits.memory=512Mi \
  --set rootUser=admin \
  --set rootPassword=password123 \
  --set mode=standalone \
  --set service.type=LoadBalancer \
  --set persistence.enabled=false \
  --version 5.4.0 \
  --wait \
  --timeout 15m
```

<br/>

```
// Патчим тип у minio-console на LoadBalancer
$ kubectl patch svc minio-console -n minio -p '{"spec": {"type": "LoadBalancer"}}'
```

<br/>

```
$ kubectl get svc -n minio
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
minio           LoadBalancer   10.100.202.79   192.168.49.20   9000:31884/TCP   4m4s
minio-console   LoadBalancer   10.111.72.199   192.168.49.21   9001:31660/TCP   4m4s
```

<br/>

```
// admin / password123
http://192.168.49.21:9001/login
```
