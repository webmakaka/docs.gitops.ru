---
layout: page
title: Istio Traffic Management
description: Istio Traffic Management
keywords: linux, kubernetes, Istio, Traffic Management
permalink: /courses/containers/kubernetes/service-mesh/istio/traffic-management/
---

# Istio Traffic Management

Поднята виртуальная машина с minikube <a href="//docs.k8s.ru/tools/containers/kubernetes/utils/service-mesh/istio/setup/">следующим образом</a>.

<br/>

Делаю:  
18.04.2020

https://www.youtube.com/watch?v=AbCiCXIHr_4

https://github.com/carnage-sh/cloud-for-fun/

<br/>

```
$ kubectl get service -n istio-system istio-ingressgateway
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                                                                                                                                      AGE
istio-ingressgateway   LoadBalancer   10.99.75.170   192.168.99.96   15020:32025/TCP,80:30850/TCP,443:31431/TCP,15029:31582/TCP,15030:30564/TCP,15031:32189/TCP,15032:30099/TCP,31400:31070/TCP,15443:30732/TCP   6m22s
```

<br/>

    // Export External-IP
    $ export GW=192.168.99.96

<br/>

    $ cd ~/tmp
    $ git clone https://github.com/carnage-sh/cloud-for-fun/
    $ cd cloud-for-fun/blog/istio-advanced-routing

<br/>

    $ kubectl apply -f 01-application.yml

<br/>

    $ kubectl get pods
    NAME                           READY   STATUS    RESTARTS   AGE
    recursed-v1-74d5694cb6-pd8d2   2/2     Running   0          80s
    recursed-v2-b4b8dcd74-jxt5t    2/2     Running   0          80s
    recursed-v3-5f849d97c5-s5b9z   2/2     Running   0          80s

<br/>

    $ kubectl apply -f 02-gateway.yml
    $ kubectl apply -f 03-route-all.yml

<br/>

    $ while true; do curl $GW/hello; sleep .3; done

    $ while true; do curl $GW/hello; sleep .3; done
    {"hostname": "recursed-v1-74d5694cb6-pd8d2", "delay": 0, "version": "v1"}
    {"hostname": "recursed-v3-5f849d97c5-s5b9z", "delay": 0, "version": "v3"}
    {"hostname": "recursed-v3-5f849d97c5-s5b9z", "delay": 0, "version": "v3"}
    {"hostname": "recursed-v2-b4b8dcd74-jxt5t", "delay": 2000, "version": "v2"}
    {"hostname": "recursed-v2-b4b8dcd74-jxt5t", "delay": 2000, "version": "v2"}
    {"hostname": "recursed-v1-74d5694cb6-pd8d2", "delay": 0, "version": "v1"}
    {"hostname": "recursed-v3-5f849d97c5-s5b9z", "delay": 0, "version": "v3"}
    {"hostname": "recursed-v2-b4b8dcd74-jxt5t", "delay": 2000, "version": "v2"}
    {"hostname": "recursed-v1-74d5694cb6-pd8d2", "delay": 0, "version": "v1"}
    {"hostname": "recursed-v3-5f849d97c5-s5b9z", "delay": 0, "version": "v3"}

<br/>

    $ ./test.sh

<br/>

    $ kubectl apply -f 04-destinationrule.yml
    $ kubectl apply -f 05-route-v1.yml
    $ kubectl apply -f 06-route-v2.yml
    $ kubectl apply -f 07-route-v1-v3.yml

<br/>

    $ kubectl apply -f 08-route-v1-mirror-v3.yml
    $ kubectl apply -f 09-route-v1-fault.yml
    $ kubectl apply -f 10-route-timeout.yml
    $ kubectl apply -f 11-dr-circuitbreaker.yml

<br/>

    $ kubectl delete -f .
