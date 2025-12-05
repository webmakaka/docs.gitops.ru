---
layout: page
title: Building CI/CD Systems Using Tekton - Getting Started with Triggers
description: Building CI/CD Systems Using Tekton - Getting Started with Triggers
keywords: books, ci-cd, tekton, Getting Started with Triggers
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/getting-started-with-triggers/
---

# Chapter 10. Getting Started with Triggers

<br/>

Делаю:  
31.08.2023

<br/>

### Installing Tekton Triggers

<br/>

```
// install the trigger custom resource definitions (CRDs)
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

// An interceptor is an object that contains the logic necessary to validate and filter webhooks coming from various sources.
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
```

<br/>

```
$ tkn version
Client version: 0.21.0
Pipeline version: v0.28.1
Triggers version: v0.16.0
```

<br/>

```
$ kubectl apply -f https://raw.githubusercontent.com/tektoncd/triggers/main/examples/rbac.yaml
```

<br/>

Now that Triggers is installed, you will be able to listen for events from GitHub, but for the webhooks to reach your cluster, you will need to expose a route to the outside world.

<br/>

### Configuring

**Using a local cluster**

Нужно зарегаться  
https://ngrok.com/download

<br/>

```
$ cd ~/tmp
$ wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
$ unzip ngrok-stable-linux-amd64.zip
$ ./ngrok authtoken <YOUR_TOKEN>
```

<br/>

**Тест:**

<br/>

```
$ python -m http.server 8000
```

OK!

<!-- <br/>

**Cloud-based clusters (GKE)**

Мне пока не нужно. Проверять не буду!

Пишут, что тестили на GKE version 1.13.7-gke.24

<br/>

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/cloud/deploy.yaml
```

<br/>

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: el-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: 'false'
spec:
  rules:
    - http:
      paths:
        - path: /
          backend:
            serviceName: <YOUR_EVENTLISTENER_NAME>
            servicePort: 8080
```

<br/>

```
$ kubectl get ingress el-ingress
``` -->
