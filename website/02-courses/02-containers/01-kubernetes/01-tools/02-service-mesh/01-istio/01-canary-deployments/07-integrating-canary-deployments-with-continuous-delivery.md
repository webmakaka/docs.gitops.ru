---
layout: page
title: Canary Deployments To Kubernetes Using Istio and Friends - Integrating Canary Deployments With Continuous Delivery
description: Canary Deployments To Kubernetes Using Istio and Friends - Integrating Canary Deployments With Continuous Delivery
keywords: linux, kubernetes, Istio, canary deployments, flagger
permalink: /courses/containers/kubernetes/service-mesh/istio/canary-deployments/integrating-canary-deployments-with-continuous-delivery/
---

# Canary Deployments To Kubernetes Using Istio and Friends

Делаю:  
21.01.2021

<br/>

# 09 Integrating Canary Deployments With Continuous Delivery

https://gist.github.com/8523efa6e7b1f0d48c1fda4f347ca55b

<br/>

```
######################
# Installing Flagger
######################
```

<br/>

```
$ kubectl apply \
 --kustomize github.com/weaveworks/flagger/kustomize/istio
```

<br/>

```
#####################
# Deploying The App
#####################
```

<br/>

```
$ cd go-demo-7
```

<br/>

```
$ kubectl create namespace go-demo-7
```

<br/>

```
$ kubectl label namespace go-demo-7 \
 istio-injection=enabled
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger-full/db \
 --recursive
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger-full/app \
 --recursive
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-primary
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get deployments
```

<br/>

```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
go-demo-7           2/2     2            2           2m19s
go-demo-7-db        1/1     1            1           2m24s
go-demo-7-primary   2/2     2            2           23s
```

<br/>

```
$ chmod +x k8s/istio/get-ingress-host.sh
```

<br/>

```
$ INGRESS_HOST=$(\
 ./k8s/istio/get-ingress-host.sh \
 $PROVIDER)
```

<br/>

```
$ echo ${INGRESS_HOST}
```

<br/>

```
$ curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/version"
```

<br/>

```
Version: 0.0.1; Release: unknown
```

<br/>

```
##############
# The Script
##############
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get canary go-demo-7 \
 --output yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get canary go-demo-7 \
 --output jsonpath="{.status.phase}"
```

<br/>

```
$ cat k8s/istio/flagger-status.sh
```

```
$ chmod +x k8s/istio/flagger-status.sh
```

<br/>

```
#####################
# Successful Canary
#####################
```

<br/>

```
$ echo ${INGRESS_HOST}
```

<br/>

```
# Open a second terminal session
```

<br/>

```
$ export INGRESS_HOST=[...]
```

<br/>

```
$ echo {INGRESS_HOST}
```

<br/>

```
$ cd ~/go-demo-7
```

<br/>

```
$ export ADDR="http://${INGRESS_HOST}/version"

$ ./k8s/istio/flagger-status.sh "$ADDR"
```

<br/>

```
# Go back to the first terminal session
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/deployment-0-0-2.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe canary go-demo-7
```

<br/>

```
# Go to the second terminal session
```

<br/>

```
echo $?
```

<br/>

```
# Go back to the first terminal session

# Wait for a while (e.g., 5 min.)
```

<br/>

```
#################
# Failed Canary
#################
```

<br/>

```
# Go to the second terminal session
```

<br/>

```
$ export ADDR="http://$INGRESS_HOST/demo/random-error"
```

<br/>

```
$ ./k8s/istio/flagger-status.sh "$ADDR"
```

<br/>

```
# Go back to the first terminal session
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/deployment-0-0-3.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe canary go-demo-7
```

<br/>

```
# Go to the second terminal session
```

<br/>

```
$ echo $?
```

<br/>

```
# Go back to the first terminal session
```

<br/>

```
###############
# Cleaning Up
###############
```

<br/>

```
$ cd ..
```

<br/>

```
$ kubectl delete namespace go-demo-7
```
