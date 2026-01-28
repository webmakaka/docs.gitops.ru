---
layout: page
title: Canary Deployments To Kubernetes Using Istio and Friends - Enabling Incoming Traffic
description: Canary Deployments To Kubernetes Using Istio and Friends - Enabling Incoming Traffic
keywords: linux, kubernetes, Istio, canary deployments
permalink: /courses/containers/kubernetes/service-mesh/istio/canary-deployments/enabling-incoming-traffic/
---

# Canary Deployments To Kubernetes Using Istio and Friends

Делаю:  
21.01.2021

<br/>

# 04 Enabling Incoming Traffic

https://gist.github.com/vfarcic/801c99d6acc5a1e68bcee2591fac90eb

<br/>

```
#################
# Using Gateway
#################
```

<br/>

```
$ cd ~

$ git clone \
 https://github.com/vfarcic/go-demo-7.git

$ cd go-demo-7

$ git pull
```

<br/>

```
$ ls -1 k8s/istio/gateway/

$ ls -1 k8s/istio/gateway/app

$ cat k8s/istio/gateway/app/istio.yaml

$ kubectl create namespace go-demo-7

$ kubectl label namespace go-demo-7 \
 istio-injection=enabled

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/gateway \
 --recursive

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-primary

$ kubectl --namespace go-demo-7 \
 get pods

$ kubectl --namespace go-demo-7 \
 get virtualservices

$ kubectl --namespace go-demo-7 \
 describe virtualservice go-demo-7

$ kubectl run curl \
 --image alpine \
 --generator "run-pod/v1" \
 -it --rm \
 -- sh -c "apk add -U curl && curl go-demo-7.go-demo-7/demo/hello"
```

<br/>

```
Flag --generator has been deprecated, has no effect and will be removed in the future.
If you don't see a command prompt, try pressing enter.
(1/5) Installing ca-certificates (20191127-r5)
(2/5) Installing brotli-libs (1.0.9-r3)
(3/5) Installing nghttp2-libs (1.42.0-r1)
(4/5) Installing libcurl (7.74.0-r0)
(5/5) Installing curl (7.74.0-r0)
Executing busybox-1.32.1-r0.trigger
Executing ca-certificates-20191127-r5.trigger
OK: 8 MiB in 19 packages
hello, Istio with version 0.0.1!
Session ended, resume using 'kubectl attach curl -c curl -i -t' command when the pod is running
pod "curl" deleted
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get ingress

$ kubectl --namespace go-demo-7 \
 get gateways

$ kubectl --namespace go-demo-7 \
 describe gateway go-demo-7
```

<br/>

```
$ export INGRESS_HOST=$(kubectl \
 --namespace istio-system \
 get service istio-ingressgateway \
 --output jsonpath="{.status.loadBalancer.ingress[0].ip}")

$ echo ${INGRESS_HOST}
```

<br/>

```
$ curl -v -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/demo/hello"

$ curl -v -H "Host: something-else.acme.com" \
 "http://$INGRESS_HOST/demo/hello"

$ kubectl --namespace go-demo-7 delete \
 --filename k8s/istio/gateway \
 --recursive
```

<br/>

```
#################
# Using Ingress
#################
```

<br/>

```
$ istioctl profile dump demo

$ ls -1 k8s/istio/ingress/app

$ cat k8s/istio/ingress/app/ingress.yaml

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/ingress/ \
 --recursive

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-primary

$ curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/demo/hello"

$ kubectl --namespace go-demo-7 delete \
 --filename k8s/istio/ingress \
 --recursive
```
