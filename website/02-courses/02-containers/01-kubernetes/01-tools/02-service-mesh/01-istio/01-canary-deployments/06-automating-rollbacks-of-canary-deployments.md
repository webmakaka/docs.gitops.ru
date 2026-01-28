---
layout: page
title: Canary Deployments To Kubernetes Using Istio and Friends - Automating Rollbacks Of Canary Deployments
description: Canary Deployments To Kubernetes Using Istio and Friends - Automating Rollbacks Of Canary Deployments
keywords: linux, kubernetes, Istio, canary deployments, flagger
permalink: /courses/containers/kubernetes/service-mesh/istio/canary-deployments/automating-rollbacks-of-canary-deployments/
---

# Canary Deployments To Kubernetes Using Istio and Friends

Делаю:  
21.01.2021

<br/>

# 08 Automating Rollbacks Of Canary Deployments

https://gist.github.com/6b3619f8fc993c0452cfae8eff0b23cc

<br/>

```
#####################
# Deploying The App
#####################
```

<br/>

```

$ cd go-demo-7

$ kubectl create namespace go-demo-7

$ kubectl label namespace go-demo-7 \
 istio-injection=enabled

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/db \
 --recursive

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/app \
 --recursive

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-primary

$ kubectl --namespace go-demo-7 \
 get deployments
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
##########################
# Rolling Back On Errors
##########################
```

<br/>

```
$ cat k8s/istio/flagger/exercise/flagger-error.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/flagger-error.yaml
```

```
$ echo $INGRESS_HOST
```

```
# Open a second terminal session
```

<br/>

```
$ export INGRESS_HOST=[...]
```

<br/>

```
$ while true; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/demo/random-error"
sleep 0.5
done
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

```
****
  Warning  Synced  15s                flagger  Halt go-demo-7.go-demo-7 advancement success rate 92.31% < 99%
```

<br/>

```
# Go to the second terminal session and stop the loop with _ctrl+c_
```

<br/>

```
########################################
# Rolling Back On Max Request Duration
########################################
```

<br/>

```
# Go to the first terminal session
```

<br/>

```
$ cat k8s/istio/flagger/exercise/flagger-max-req-duration.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/flagger-max-req-duration.yaml
```

<br/>

```
# Go to second terminal session
```

<br/>

```
$ while true; do
DELAY=$[ $RANDOM % 3000 ]
    curl -H "Host: go-demo-7.acme.com" \
        "http://${INGRESS_HOST}/demo/hello?delay=$DELAY"
done
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

```
***
  Normal   Synced  89s (x2 over 67m)    flagger  Advance go-demo-7.go-demo-7 canary weight 20
  Warning  Synced  29s                  flagger  Halt go-demo-7.go-demo-7 advancement success rate 90.19% < 99%
```

<br/>

```
# Go to the second terminal and stop the loop with _ctrl+c_
```

<br/>

```
###################
# Rolling Forward
###################
```

<br/>

```
# Go to second terminal session
```

<br/>

```
$ while true; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/demo/hello"
sleep 0.5
done
```

<br/>

```
# Go back to the first terminal session
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/deployment-0-0-5.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe canary go-demo-7
```

<br/>

```
# Go to the second terminal and stop the loop with _ctrl+c_
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

$ kubectl delete namespace go-demo-7
```
