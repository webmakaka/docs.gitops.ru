---
layout: page
title: Istio в minikube
description: Istio в minikube
keywords: linux, kubernetes, Istio, MiniKube
permalink: /courses/containers/kubernetes/service-mesh/istio/minikube/11-steps-to-awesome-with-kubernetes/
---

# Istio в minikube.

**Примеры из курса "11 Steps to Awesome with Kubernetes, Istio, and Knative LiveLessons"**

Делаю:  
22.04.2020

https://github.com/redhat-developer-demos/istio-tutorial

http://github.com/burrsutter/scripts-istio

<br/>

    $ istioctl manifest apply --set profile=demo

<br/>

    $ kubectl label namespace default istio-injection=enabled

<br/>

### Deploy with Istio Envoy Sidecars

    $ kubectl create namespace tutorial
    $ kubectl config set-context $(kubectl config current-context) --namespace=tutorial

<br/>

    $ mkdir -p ~/tmp/istio && cd ~/tmp/istio

    $ git clone https://github.com/redhat-developer-demos/istio-tutorial

    $ cd istio-tutorial/

    $ istioctl kube-inject -f customer/kubernetes/Deployment.yml
    $ kubectl label namespace tutorial istio-injection=enabled

<br/>

    $ kubectl get namespaces --show-labels
    ***
    tutorial          Active   8m33s   istio-injection=enabled

<br/>

    $ kubectl apply -f customer/kubernetes/Deployment.yml

<br/>

    $ kubectl get pods
    NAME                        READY   STATUS    RESTARTS   AGE
    customer-6948b8b959-v4cg8   2/2     Running   0          26s

<br/>

    $ kubectl apply -f customer/kubernetes/Service.yml
    $ kubectl apply -f customer/kubernetes/Gateway.yml

    $ kubectl apply -f preference/kubernetes/Deployment.yml
    $ kubectl apply -f preference/kubernetes/Service.yml

    $ kubectl apply -f recommendation/kubernetes/Deployment.yml
    $ kubectl apply -f recommendation/kubernetes/Service.yml

<br/>

    $ kubectl get services
    NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
    customer         ClusterIP   10.110.254.99    <none>        8080/TCP   39s
    preference       ClusterIP   10.108.86.218    <none>        8080/TCP   24s
    recommendation   ClusterIP   10.111.135.119   <none>        8080/TCP   18s

<br/>

    $ kubectl get vs
    NAME               GATEWAYS             HOSTS   AGE
    customer-gateway   [customer-gateway]   [*]     50s

<br/>

    $ kubectl get service -n istio-system istio-ingressgateway

Вижу -> 30850/TCP

    $ minikube --profile my-profile ip
    192.168.99.120

```
$ while true; do curl 192.168.99.120:30850/customer; sleep .3; done
customer => preference => recommendation v1 from 'f11b097f1dd0': 12
customer => preference => recommendation v1 from 'f11b097f1dd0': 13
customer => preference => recommendation v1 from 'f11b097f1dd0': 14
customer => preference => recommendation v1 from 'f11b097f1dd0': 15
customer => preference => recommendation v1 from 'f11b097f1dd0': 16
customer => preference => recommendation v1 from 'f11b097f1dd0': 17
customer => preference => recommendation v1 from 'f11b097f1dd0': 18
customer => preference => recommendation v1 from 'f11b097f1dd0': 19
customer => preference => recommendation v1 from 'f11b097f1dd0': 20
customer => preference => recommendation v1 from 'f11b097f1dd0': 21
customer => preference => recommendation v1 from 'f11b097f1dd0': 22
customer => preference => recommendation v1 from 'f11b097f1dd0': 23
customer => preference => recommendation v1 from 'f11b097f1dd0': 24
customer => preference => recommendation v1 from 'f11b097f1dd0': 25
```

<br/>

### Shift traffic with VirtualService and DestinationRule

https://redhat-developer-demos.github.io/istio-tutorial/istio-tutorial/1.3.x/4simple-routerules.html

    $ kubectl apply -f recommendation/kubernetes/Deployment-v2.yml

    $ while true; do curl 192.168.99.120:30850/customer; sleep .3; done
    customer => preference => recommendation v2 from '3cbba7a9cde5': 1
    customer => preference => recommendation v1 from 'f11b097f1dd0': 26
    customer => preference => recommendation v2 from '3cbba7a9cde5': 2
    customer => preference => recommendation v1 from 'f11b097f1dd0': 27
    customer => preference => recommendation v2 from '3cbba7a9cde5': 3
    customer => preference => recommendation v1 from 'f11b097f1dd0': 28
    customer => preference => recommendation v2 from '3cbba7a9cde5': 4
    customer => preference => recommendation v1 from 'f11b097f1dd0': 29
    customer => preference => recommendation v2 from '3cbba7a9cde5': 5
    customer => preference => recommendation v1 from 'f11b097f1dd0': 30
    customer => preference => recommendation v2 from '3cbba7a9cde5': 6
    customer => preference => recommendation v1 from 'f11b097f1dd0': 31
    customer => preference => recommendation v2 from '3cbba7a9cde5': 7
    customer => preference => recommendation v1 from 'f11b097f1dd0': 32
    customer => preference => recommendation v2 from '3cbba7a9cde5': 8

<br/>

    $ kubectl get pods --show-labels
    ***
    recommendation-v1-69db8d6c48-2x244   2/2     Running   0          15m     app=recommendation,pod-template-hash=69db8d6c48,security.istio.io/tlsMode=istio,service.istio.io/canonical-name=recommendation,service.istio.io/canonical-revision=v1,version=v1
    recommendation-v2-6c5b86bbd8-q9gtv   2/2     Running   0          2m42s   app=recommendation,pod-template-hash=6c5b86bbd8,security.istio.io/tlsMode=istio,service.istio.io/canonical-name=recommendation,service.istio.io/canonical-revision=v2,version=v2

<br/>

    $ kubectl scale --replicas=2 deployment/recommendation-v2 -n tutorial

<br/>

    $ kubectl scale --replicas=1 deployment/recommendation-v2 -n tutorial

<br/>

    $ {
        kubectl create -f istiofiles/destination-rule-recommendation-v1-v2.yml -n tutorial
        kubectl create -f istiofiles/virtual-service-recommendation-v2.yml -n tutorial
    }

```
$ while true; do curl 192.168.99.120:30850/customer; sleep .3; done
customer => preference => recommendation v2 from '3cbba7a9cde5': 9
customer => preference => recommendation v2 from '3cbba7a9cde5': 10
customer => preference => recommendation v2 from '3cbba7a9cde5': 11
customer => preference => recommendation v2 from '3cbba7a9cde5': 12
customer => preference => recommendation v2 from '3cbba7a9cde5': 13
customer => preference => recommendation v2 from '3cbba7a9cde5': 14
customer => preference => recommendation v2 from '3cbba7a9cde5': 15
customer => preference => recommendation v2 from '3cbba7a9cde5': 16
customer => preference => recommendation v2 from '3cbba7a9cde5': 17
customer => preference => recommendation v2 from '3cbba7a9cde5': 18
customer => preference => recommendation v2 from '3cbba7a9cde5': 19
customer => preference => recommendation v2 from '3cbba7a9cde5': 20
customer => preference => recommendation v2 from '3cbba7a9cde5': 21
customer => preference => recommendation v2 from '3cbba7a9cde5': 22
customer => preference => recommendation v2 from '3cbba7a9cde5': 23
customer => preference => recommendation v2 from '3cbba7a9cde5': 24
```

<br/>

    $ kubectl get virtualservices
    NAME               GATEWAYS             HOSTS              AGE
    customer-gateway   [customer-gateway]   [*]                20m
    recommendation                          [recommendation]   83s

<br/>

    $ kubectl get destinationrules
    NAME             HOST             AGE
    recommendation   recommendation   114s

<br/>

    $ kubectl describe vs recommendation

Weight: 100

<br/>

    $ kubectl edit vs/recommendation

subset: version-v1

```
$ while true; do curl 192.168.99.120:30850/customer; sleep .3; done
customer => preference => recommendation v1 from 'f11b097f1dd0': 33
customer => preference => recommendation v1 from 'f11b097f1dd0': 34
customer => preference => recommendation v1 from 'f11b097f1dd0': 35
customer => preference => recommendation v1 from 'f11b097f1dd0': 36
customer => preference => recommendation v1 from 'f11b097f1dd0': 37
customer => preference => recommendation v1 from 'f11b097f1dd0': 38
customer => preference => recommendation v1 from 'f11b097f1dd0': 39
customer => preference => recommendation v1 from 'f11b097f1dd0': 40

```

<br/>

    $ kubectl delete dr recommendation
    $ kubectl delete vs recommendation

<br/>

    $ kubectl delete -f istiofiles/virtual-service-recommendation-v1_and_v2_75_25.yml -n tutorial

<br/>

    $ kubectl delete -f istiofiles/destination-rule-recommendation-v1-v2.yml -n tutorial

<br/>

### Perform smarter canary deployments

    $ kubectl apply -f istiofiles/destination-rule-recommendation-v1-v2.yml -n tutorial
    $ kubectl apply -f istiofiles/virtual-service-recommendation-v1_and_v2.yml -n tutorial

```
$ while true; do curl 192.168.99.120:30850/customer; sleep .3; done
customer => preference => recommendation v2 from '3cbba7a9cde5': 45
customer => preference => recommendation v1 from 'f11b097f1dd0': 41
customer => preference => recommendation v1 from 'f11b097f1dd0': 42
customer => preference => recommendation v1 from 'f11b097f1dd0': 43
customer => preference => recommendation v2 from '3cbba7a9cde5': 46
customer => preference => recommendation v1 from 'f11b097f1dd0': 44
customer => preference => recommendation v1 from 'f11b097f1dd0': 45
customer => preference => recommendation v1 from 'f11b097f1dd0': 46
customer => preference => recommendation v1 from 'f11b097f1dd0': 47
customer => preference => recommendation v1 from 'f11b097f1dd0': 48
customer => preference => recommendation v1 from 'f11b097f1dd0': 49
customer => preference => recommendation v2 from '3cbba7a9cde5': 47
customer => preference => recommendation v1 from 'f11b097f1dd0': 50
customer => preference => recommendation v1 from 'f11b097f1dd0': 51
customer => preference => recommendation v1 from 'f11b097f1dd0': 52
customer => preference => recommendation v1 from 'f11b097f1dd0': 53
customer => preference => recommendation v1 from 'f11b097f1dd0': 54
customer => preference => recommendation v1 from 'f11b097f1dd0': 55
customer => preference => recommendation v1 from 'f11b097f1dd0': 56
customer => preference => recommendation v1 from 'f11b097f1dd0': 57
```

<br/>

    $ kubectl edit vs recommendation

60 / 40

    $ kubectl delete vs recommendation
    $ kubectl delete dr recommendation

<br/>

    $ ./scripts/clean.sh

<br/>

Далее примеры, где в зависимости от браузера, региона, залогинен пользователь или нет - отдавать контент из определенного сервиса.

https://redhat-developer-demos.github.io/istio-tutorial/istio-tutorial/1.3.x/4advanced-routerules.html

<br/>

### Practice mirroring and the dark launch

https://redhat-developer-demos.github.io/istio-tutorial/istio-tutorial/1.3.x/4advanced-routerules.html#mirroringtraffic

    $ kubectl create -f istiofiles/destination-rule-recommendation-v1-v2.yml -n tutorial

    $ kubectl create -f istiofiles/virtual-service-recommendation-v1-mirror-v2.yml -n tutorial

```
$ while true; do curl 192.168.99.120:30850/customer; sleep .3; done
customer => preference => recommendation v1 from 'f11b097f1dd0': 105
customer => preference => recommendation v1 from 'f11b097f1dd0': 106
customer => preference => recommendation v1 from 'f11b097f1dd0': 107
customer => preference => recommendation v1 from 'f11b097f1dd0': 108
customer => preference => recommendation v1 from 'f11b097f1dd0': 109
customer => preference => recommendation v1 from 'f11b097f1dd0': 110
customer => preference => recommendation v1 from 'f11b097f1dd0': 111
```

Видим только v1

В общем, если правильно понял. v2 отработает только в случае ошибки.

<br/>

### Explore observability - Grafana, Jaeger, Kiali

<!--

    $ git clone http://github.com/burrsutter/scripts-istio
    $ cd scripts-istio/

-->

```
$ {
kubectl patch service/grafana -p '{"spec":{"type":"NodePort"}}' -n istio-system

echo http://$(minikube --profile my-profile ip):$(kubectl get svc grafana -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

kubectl patch service/jaeger-query -p '{"spec":{"type":"NodePort"}}' -n istio-system

echo http://$(minikube --profile my-profile ip):$(kubectl get svc jaeger-query -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

kubectl patch service/prometheus -p '{"spec":{"type":"NodePort"}}' -n istio-system

echo http://$(minikube --profile my-profile ip):$(kubectl get svc prometheus -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

kubectl patch service/kiali -p '{"spec":{"type":"NodePort"}}' -n istio-system

echo http://$(minikube --profile my-profile ip):$(kubectl get svc kiali -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')/kiali

}

```

<br/>

### Inject Chaos

https://redhat-developer-demos.github.io/istio-tutorial/istio-tutorial/1.3.x/6fault-injection.html

<br/>

    // HTTP Error 503
    $ {
        kubectl create -f istiofiles/destination-rule-recommendation.yml -n tutorial
        kubectl create -f istiofiles/virtual-service-recommendation-503.yml -n tutorial
    }


    $ kubectl delete -f istiofiles/virtual-service-recommendation-503.yml -n tutorial

<br/>

    // Delay
    $ {
        kubectl create -f istiofiles/virtual-service-recommendation-delay.yml -n tutorial
        kubectl replace -f istiofiles/destination-rule-recommendation.yml -n tutorial
    }

<br/>

    $ {
        kubectl delete -f istiofiles/destination-rule-recommendation.yml -n tutorial
        kubectl delete -f istiofiles/virtual-service-recommendation-delay.yml -n tutorial
    }

<br/>

### Add resiliency

https://redhat-developer-demos.github.io/istio-tutorial/istio-tutorial/1.3.x/5circuit-breaker.html#timeout

    $ kubectl edit deployment recommendation-v2

Имидж

    istio-tutorial-recommendation:v2.1-timeout

<br/>

    $ kubectl create -f istiofiles/virtual-service-recommendation-timeout.yml -n tutorial

<br/>

    $ kubectl edit deployment recommendation-v2

Имидж

    istio-tutorial-recommendation:v2.1-timeout

<br/>

### Add security

https://github.com/burrsutter/scripts-istio/tree/master/egress_demo

// Create a namespace and make it "sticky"

    $ kubectl create namespace egresstest
    $ kubectl config set-context --current --namespace=egresstest
    $ kubectl label namespace egresstest istio-injection=enabled

// Check the Configmap

    $ kubectl get configmap istio -n istio-system -o yaml | grep -o "mode: ALLOW_ANY"
    mode: ALLOW_ANY

// Create a Deployment and find its Pod

    $ kubectl create deployment nginx --image=nginx
    $ NGINXPOD=$(kubectl get pods -l app=nginx -o 'jsonpath={.items[0].metadata.name}')

    $ kubectl exec -it $NGINXPOD /bin/bash

<br/>

    # apt-get update # note: this will fail if egress is blocked
    # apt-get -y install curl

    # curl httpbin.org/user-agent

    # curl http://worldclockapi.com/api/json/cet/now

    exit

<br/>

// Now, block egress

    $ kubectl get configmap istio -n istio-system -o yaml \
        | sed 's/mode: ALLOW_ANY/mode: REGISTRY_ONLY/g' | \
        kubectl replace -n istio-system -f -

    $ kubectl get configmap istio -n istio-system -o yaml | grep -o "mode: REGISTRY_ONLY"

<br/>

// Selectively open up egress

    $ kubectl apply -f istiofiles/service-entry-egress-worldclockapi.yml
