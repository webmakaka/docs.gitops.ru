---
layout: page
title: Istio Request Routing
description: Istio Request Routing
keywords: linux, kubernetes, Istio, Request Routing
permalink: /courses/containers/kubernetes/service-mesh/istio/request-routing/
---

# Istio Request Routing

Поднята виртуальная машина с minikube <a href="//docs.k8s.ru/tools/containers/kubernetes/utils/service-mesh/istio/setup/">следующим образом</a>.

<br/>

Делаю:  
19.01.2021

https://www.youtube.com/watch?v=a0Mu0hQ9zzI

https://github.com/carnage-sh/cloud-for-fun/tree/master/blog/istio-routing

<br/>

```
$ export INGRESS_HOST=$(kubectl \
 --namespace istio-system \
 get service istio-ingressgateway \
 --output jsonpath="{.status.loadBalancer.ingress[0].ip}")

$ echo ${INGRESS_HOST}
```

<br/>

    $ cd ~/
    $ git clone https://github.com/carnage-sh/cloud-for-fun/
    $ cd cloud-for-fun/blog/istio-routing

<br/>

    $ kubectl apply -f helloworld-gateway-v1.yaml
    $ kubectl apply -f helloworld-gateway-v2.yaml

<br/>

Оригинальный файл helloworld-v1.yaml устарел.

<br/>

```
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: helloworld-v1
  labels:
    app: helloworld
spec:
  ports:
  - port: 5000
    name: http
  selector:
    app: helloworld
    version: v1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-v1
  labels:
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
  template:
    metadata:
      labels:
        app: helloworld
        version: v1
    spec:
      containers:
      - name: helloworld
        image: istio/examples-helloworld-v1
        resources:
          requests:
            cpu: "100m"
        imagePullPolicy: IfNotPresent #Always
        ports:
        - containerPort: 5000
EOF
```

<br/>

Оригинальный файл helloworld-v2.yaml устарел.

<br/>

```
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: helloworld-v2
  labels:
    app: helloworld
spec:
  ports:
  - port: 5000
    name: http
  selector:
    app: helloworld
    version: v2
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-v2
  labels:
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
  template:
    metadata:
      labels:
        app: helloworld
        version: v2
    spec:
      containers:
      - name: helloworld
        image: istio/examples-helloworld-v2
        resources:
          requests:
            cpu: "100m"
        imagePullPolicy: IfNotPresent #Always
        ports:
        - containerPort: 5000
EOF
```

<br/>

```
$ kubectl get pods
NAME READY STATUS RESTARTS AGE
helloworld-v1-7476658d4f-vpqx9 1/1 Running 0 8m7s
helloworld-v2-786b58884c-g9vs5 1/1 Running 0 10s

```

<!--

<br/>

    // Или посмотреть EXTERNAL-IP
    $ kubectl get service -n istio-system istio-ingressgateway

-->

<br/>

    $ curl $INGRESS_HOST
    Hello version: v1, instance: helloworld-v1-7695cb4556-9dnsx

<br/>

    $ curl $INGRESS_HOST -H 'x-user: gregory'
    Hello version: v2, instance: helloworld-v2-58b576ddf4-49zds

<br/>

В общем для "gregory" выделенный сервис.

<br/>

    $ kubectl get vs
    NAME         GATEWAYS               HOSTS   AGE
    helloworld   [helloworld-gateway]   [*]     3m44s

<br/>

    $ kubectl get svc
    NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
    helloworld-v1   ClusterIP   10.101.16.86     <none>        5000/TCP   6m10s
    helloworld-v2   ClusterIP   10.110.180.253   <none>        5000/TCP   3m53s
    kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP    7m56s
