---
layout: page
title: Canary Deployments To Kubernetes Using Istio and Friends - Using Metrics To Validate Progress
description: Canary Deployments To Kubernetes Using Istio and Friends - Using Metrics To Validate Progress
keywords: linux, kubernetes, Istio, canary deployments, metrics
permalink: /courses/containers/kubernetes/service-mesh/istio/canary-deployments/using-metrics-to-validate-progress/
---

# Canary Deployments To Kubernetes Using Istio and Friends

Делаю:  
21.01.2021

<br/>

# 06 Using Metrics To Validate Progress

https://gist.github.com/5b3cd6f336e2d9e6682c1a1792c860d0

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
 --filename k8s/istio/split/db \
 --recursive

$ kubectl --namespace go-demo-7 apply \
 --filename k8s/istio/split/app \
 --recursive

$ kubectl --namespace go-demo-7 \
 rollout status \
 deployment go-demo-7-primary

$ chmod +x k8s/istio/get-ingress-host.sh

$ INGRESS_HOST=$(\
 ./k8s/istio/get-ingress-host.sh \
 $PROVIDER)

$ echo ${INGRESS_HOST}

$ curl -H "Host: go-demo-7.acme.com" \
 "http://${INGRESS_HOST}/version"
```

<br/>

```
####################
# Querying Metrics
####################
```

<br/>

```
$ kubectl --namespace istio-system \
 get service prometheus
```

<br/>

**Если нет сервиса:**

<br/>

```
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/prometheus.yaml
```

<br/>

```
$ kubectl --namespace istio-system \
 port-forward $(kubectl \
 --namespace istio-system \
 get pod \
 --selector app=prometheus \
 --output jsonpath='{.items[0].metadata.name}') \
 9090:9090 &
```

<br/>

Browser: http://localhost:9090

<br/>

```
$ for i in {1..300}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://${INGRESS_HOST}/version"
sleep 0.1
done
```

<br/>

```
# Execute the following prometheus queries:

# istio_requests_total

# istio_requests_total{destination_workload="go-demo-7-primary", reporter="destination"}

# istio_request_duration_milliseconds_sum{destination_workload="go-demo-7-primary", reporter="destination"}

# istio_request_duration_milliseconds_bucket{destination_workload="go-demo-7-primary", reporter="destination"}
```

<br/>

```
##############
# Error Rate
##############
```

<br/>

```
$ for i in {1..300}; do
curl -H "Host: go-demo-7.acme.com" \
 "http://$INGRESS_HOST/demo/random-error"
sleep 0.1
done
```

<br/>

```
# Execute the following prometheus queries:

# sum(rate(istio_requests_total{destination_workload="go-demo-7-primary", reporter="destination"}[1m]))

# sum(rate(istio_requests_total{destination_workload="go-demo-7-primary", reporter="destination",response_code!~"5.\*"}[1m]))

# sum(rate(istio_requests_total{destination_workload="go-demo-7-primary", reporter="destination",response_code!~"5.\*"}[1m])) / sum(rate(istio_requests_total{destination_workload="go-demo-7-primary", reporter="destination"}[1m]))
```

<br/>

```
############################
# Average Request Duration
############################
```

<br/>

```
$ for i in {1..100}; do
DELAY=$[ $RANDOM % 1000 ]
    curl -H "Host: go-demo-7.acme.com" \
        "http://${INGRESS_HOST}/demo/hello?delay=$DELAY"
done
```

<br/>

```
# Execute the following prometheus queries:

# sum(rate(istio_request_duration_milliseconds_sum{destination_workload="go-demo-7-primary", reporter="destination"}[1m]))

# sum(rate(istio_request_duration_milliseconds_sum{destination_workload="go-demo-7-primary", reporter="destination"}[1m])) / sum(rate(istio_request_duration_milliseconds_count{destination_workload="go-demo-7-primary", reporter="destination"}[1m]))
```

<br/>

```
########################
# Max Request Duration
########################
```

<br/>

```
$ for i in {1..100}; do
DELAY=$[ $RANDOM % 2000 ]
    curl -H "Host: go-demo-7.acme.com" \
        "http://$INGRESS_HOST/demo/hello?delay=$DELAY"
done
```

<br/>

```
# histogram_quantile(0.95, sum(irate(istio_request_duration_milliseconds_bucket{destination_workload="go-demo-7-primary"}[1m])) by (le))
```

<br/>

```
#######################
# Visualizing Metrics
#######################
```

<br/>

```
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/grafana.yaml
```

<br/>

```
$ kubectl --namespace istio-system \
 get service grafana
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

Browser: http://localhost:3000
