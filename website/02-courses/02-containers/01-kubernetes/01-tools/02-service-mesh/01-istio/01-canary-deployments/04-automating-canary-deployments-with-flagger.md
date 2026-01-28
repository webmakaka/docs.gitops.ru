---
layout: page
title: Canary Deployments To Kubernetes Using Istio and Friends - Automating Canary Deployments With Flagger
description: Canary Deployments To Kubernetes Using Istio and Friends - Automating Canary Deployments With Flagger
keywords: linux, kubernetes, Istio, canary deployments, flagger
permalink: /courses/containers/kubernetes/service-mesh/istio/canary-deployments/automating-canary-deployments-with-flagger/
---

# Canary Deployments To Kubernetes Using Istio and Friends

Делаю:  
21.01.2021

<br/>

# 07 Automating Canary Deployments With Flagger

https://gist.github.com/96be243dcf4d3768c8b059c16c34fa79

<br/>

**Возможно нужно, но я точно не знаю:**

<br/>

```
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/prometheus.yaml
```

```
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/grafana.yaml
```

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
$ export GH_USER=vfarcic

$ cd ~

$ git clone \
 https://github.com/$GH_USER/go-demo-7.git

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
 --filename k8s/db \
 --recursive
```

<br/>

```
$ ls -l k8s/app

$ cat k8s/app/*
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/app \
 --recursive
```

<br/>

```
$ kubectl --namespace go-demo-7 rollout status deployment go-demo-7
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
$ curl -v -H "Host: go-demo-7.acme.com" \
 "http://${INGRESS_HOST}/version"
```

<br/>

```
curl: (7) Failed to connect to 192.168.49.20 port 80: Connection refused
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get gateways,ingresses
```

<br/>

```
No resources found in go-demo-7 namespace.
```

<br/>

```
##############################
# Deploying Flagger Resource
##############################
```

<br/>

```
$ cat k8s/istio/flagger/exercise/flagger.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/flagger.yaml
```

<br/>

```
$ cat k8s/istio/flagger/exercise/gateway.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/gateway.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get deployments
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
 get hpa
```

<br/>

```
# Might be `<unknown>` if metrics server is not installed
```

<br/>

```
$ for i in {1..10}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/version"
sleep 0.25
done
```

<br/>

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
$ kubectl --namespace go-demo-7 \
 get services
```

```
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
go-demo-7           ClusterIP   10.103.68.154    <none>        80/TCP      7m21s
go-demo-7-canary    ClusterIP   10.100.79.47     <none>        80/TCP      8m21s
go-demo-7-db        ClusterIP   10.105.27.5      <none>        27017/TCP   50m
go-demo-7-primary   ClusterIP   10.103.249.225   <none>        80/TCP      8m21s
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get destinationrules
```

```
NAME                HOST                AGE
go-demo-7-canary    go-demo-7-canary    8m4s
go-demo-7-primary   go-demo-7-primary   8m4s
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get virtualservices
```

```
NAME        GATEWAYS        HOSTS                                AGE
go-demo-7   ["go-demo-7"]   ["go-demo-7.acme.com","go-demo-7"]   8m39s

```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get canaries
```

```
NAME        STATUS        WEIGHT   LASTTRANSITIONTIME
go-demo-7   Initialized   0        2021-01-21T17:06:13Z
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe canary go-demo-7
```

<br/>

```
###########################
# Deploying A New Release
###########################
```

<br/>

```
$ cat k8s/istio/flagger/exercise/deployment-0-0-2.yaml
```

<br/>

```
$ diff k8s/app/deployment.yaml \
 k8s/istio/flagger/exercise/deployment-0-0-2.yaml
```

<br/

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
$ while true; do
curl -H "Host: go-demo-7.acme.com" \
 "http://${INGRESS_HOST}/version"
sleep 1
done
```

<br/>

```
# Go back to the first terminal session
```

```
$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/flagger/exercise/deployment-0-0-2.yaml
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get deployments
```

<br/>

```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
go-demo-7           2/2     2            2           159m
go-demo-7-db        1/1     1            1           161m
go-demo-7-primary   2/2     2            2           118m
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get virtualservices
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe virtualservice go-demo-7
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get pods
```

<br/>

```
NAME                                 READY   STATUS    RESTARTS   AGE
go-demo-7-6d47f98d98-6vsvh           2/2     Running   0          83s
go-demo-7-6d47f98d98-pjbvj           2/2     Running   0          81s
go-demo-7-db-dbd659775-vpqx9         2/2     Running   0          161m
go-demo-7-primary-5b46c7c88b-7pccx   2/2     Running   0          119m
go-demo-7-primary-5b46c7c88b-cprq8   2/2     Running   0          119m
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 get canaries
```

<br/>

```
NAME        STATUS        WEIGHT   LASTTRANSITIONTIME
go-demo-7   Progressing   20       2021-01-21T19:04:13Z
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe canary go-demo-7
```

<br/>

```
$ kubectl --namespace go-demo-7 \
 describe virtualservice go-demo-7
```

```
$ kubectl --namespace go-demo-7 \
 get canaries
```

<br/>

```
# Go to the second terminal session and stop the loop with _ctrl+c_
```

<br/>

```
#######################
# Visualizing Metrics
#######################
```

<br/>

```
# Go to the first terminal session
```

<br/>

```
$ istioctl manifest install \
 --set values.grafana.enabled=true
```

<br/>

```
$ kubectl --namespace istio-system \
 port-forward $(kubectl \
 --namespace istio-system \
 get pod \
 --selector app=grafana \
 --output jsonpath='{.items[0].metadata.name}') \
 3000:3000 &
```

<br/>

```
$ cat k8s/grafana/flagger.json
```

<br/>

```
# Copy the JSON
```

open "http://localhost:3000/dashboard/import"

```
# Paste the JSON
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

$ killall kubectl

$ kubectl delete namespace go-demo-7
```
