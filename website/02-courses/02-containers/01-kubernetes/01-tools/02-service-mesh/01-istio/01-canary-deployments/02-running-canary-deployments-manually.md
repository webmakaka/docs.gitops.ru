---
layout: page
title: Canary Deployments To Kubernetes Using Istio and Friends - Running Canary Deployments Manually
description: Canary Deployments To Kubernetes Using Istio and Friends - Running Canary Deployments Manually
keywords: linux, kubernetes, Istio, canary deployments
permalink: /courses/containers/kubernetes/service-mesh/istio/canary-deployments/running-canary-deployments-manually/
---

# Canary Deployments To Kubernetes Using Istio and Friends

Делаю:  
21.01.2021

<br/>

# 05 Running Canary Deployments Manually

https://gist.github.com/5aa9bb94fb9192b6865b7100534ea027

<br/>

```
$ export GH_USER=vfarcic

$ cd ~

$ git clone \
 https://github.com/$GH_USER/go-demo-7.git

$ cd go-demo-7
```

<br/>

```
################
# Fist Release
################
```

<br/>

```
$ kubectl create namespace go-demo-7

$ kubectl label namespace go-demo-7 \
 istio-injection=enabled

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/gateway/ \
 --recursive

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-primary

$ chmod +x k8s/istio/get-ingress-host.sh

$ INGRESS_HOST=$(\
 ./k8s/istio/get-ingress-host.sh \
 $PROVIDER)

$ echo ${INGRESS_HOST}

```

<br/>

```
$ for i in {1..10}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://${INGRESS_HOST}/version"
done
```

**response:**

```
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
```

<br/>

```
$ kubectl --namespace go-demo-7 get pods
NAME                                 READY   STATUS    RESTARTS   AGE
go-demo-7-db-dbd659775-r5khk         2/2     Running   0          9m3s
go-demo-7-primary-7cdff5b4f7-g9vs5   2/2     Running   2          9m3s
go-demo-7-primary-7cdff5b4f7-j9b8x   2/2     Running   2          9m3s
go-demo-7-primary-7cdff5b4f7-vpqx9   2/2     Running   2          9m3s
```

<br/>

```
###############
# New Release
###############
```

<br/>

```
$ cat k8s/istio/split/exercise/app-0-0-2-canary.yaml

$ diff k8s/istio/gateway/app/deployment.yaml \
 k8s/istio/split/exercise/app-0-0-2-canary.yaml

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/exercise/app-0-0-2-canary.yaml

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-canary
```

<br/>

```
$ kubectl --namespace go-demo-7 get pods
NAME                                 READY   STATUS    RESTARTS   AGE
go-demo-7-canary-5d77fff5fc-5bphr    2/2     Running   0          68s
go-demo-7-db-dbd659775-r5khk         2/2     Running   0          44m
go-demo-7-primary-7cdff5b4f7-g9vs5   2/2     Running   2          44m
go-demo-7-primary-7cdff5b4f7-j9b8x   2/2     Running   2          44m
go-demo-7-primary-7cdff5b4f7-vpqx9   2/2     Running   2          44m
```

<br/>

```
$ kubectl --namespace go-demo-7 \
>  get deployments
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
go-demo-7-canary    1/1     1            1           18m
go-demo-7-db        1/1     1            1           61m
go-demo-7-primary   3/3     3            3           61m
```

<br/>

```
$ for i in {1..100}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://${INGRESS_HOST}/version"
done
```

```
***
Version: 0.0.2; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.2; Release: unknown
Version: 0.0.1; Release: unknown
Version: 0.0.1; Release: unknown
***
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe service go-demo-7

$ kubectl --namespace go-demo-7 \
 describe virtualservice go-demo-7

$ kubectl --namespace go-demo-7 \
 describe gateway go-demo-7
```

<br/>

```
#####################
# Splitting Traffic
#####################
```

<br/>

```
$ cat k8s/istio/split/exercise/host20.yaml

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/exercise/host20.yaml
```

<br/>

```
$ for i in {1..100}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://${INGRESS_HOST}/version"
done
```

<br/>

```
$ kubectl --namespace go-demo-7 delete \
 --filename k8s/istio/split/exercise/host20.yaml
```

<br/>

**Better aproach**

```
$ cat k8s/istio/split/exercise/split20.yaml

# NOTE: The sum of all `weight` entries must be 100

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/exercise/split20.yaml
```

<br/>

```
$ for i in {1..100}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/version"
done
```

<br/>

```
###################
# Rolling Forward
###################
```

<br/>

```

$ cat k8s/istio/split/exercise/split40.yaml

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/exercise/split40.yaml

```

<br/>

```
$ for i in {1..100}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/version"
done
```

<br/>

```
$ cat k8s/istio/split/exercise/split60.yaml

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/exercise/split60.yaml
```

<br/>

```
$ for i in {1..100}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/version"
done
```

<br/>

```
############################
# Finishing The Deployment
############################
```

<br/>

```
$ cat k8s/istio/split/exercise/app-0-0-2.yaml

$ diff k8s/istio/gateway/app/deployment.yaml \
 k8s/istio/split/exercise/app-0-0-2.yaml

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/exercise/app-0-0-2.yaml

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-primary
```

<br/>

```
$ for i in {1..100}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/version"
done
```

```
Version: 0.0.2; Release: canary
Version: 0.0.2; Release: canary
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: canary
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: canary
Version: 0.0.2; Release: canary
Version: 0.0.2; Release: canary
```

<br/>

```
$ cat k8s/istio/split/exercise/split100.yaml

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/exercise/split100.yaml
```

<br/>

```
$ for i in {1..100}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/version"
done
```

```
***
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: primary
Version: 0.0.2; Release: primary
***
```

<br/>

```
$ kubectl --namespace go-demo-7 \
>  get deployments
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
go-demo-7-canary    0/0     0            0           136m
go-demo-7-db        1/1     1            1           3h
go-demo-7-primary   3/3     3            3           3h
```
