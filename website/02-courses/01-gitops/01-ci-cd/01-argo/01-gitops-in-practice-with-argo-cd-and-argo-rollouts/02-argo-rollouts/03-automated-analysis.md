---
layout: page
title: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Automated Analysis
description: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Automated Analysis
keywords: courses, gitops, argo, GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Automated Analysis
permalink: /courses/gitops/ci-cd/argo/gitops-in-practice-with-argo-cd-and-argo-rollouts/argo-rollouts/automated-analysis/
---

# [Lauro Fialho Müller] GitOps in Practice with Argo CD and Argo Rollouts [ENG, 2026]: Argo Rollouts: Automated Analysis

<br/>

**Делаю:**  
2026.01.29

<br/>

Делаем на чистый стенд. Установлен только argo-rollout.

<br/>

**Дока по инсталляции prometheus:**  
https://github.com/lm-academy/argo-rollouts-course/tree/main/setup-prometheus

<br/>

Устанавливаем самую простую версию без grafana.

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > prometheus-values.yaml << 'EOF'
server:
  global:
    scrape_interval: 15s
  service:
    type: NodePort
    nodePort: 30090
EOF
```

<br/>

```
$ helm upgrade \
    --install prometheus prometheus-community/prometheus \
    --namespace monitoring \
    --create-namespace \
    --version 27.49.0 \
    --values prometheus-values.yaml
```

<br/>

```
$ kubectl get pods -n monitoring
NAME                                                 READY   STATUS    RESTARTS   AGE
prometheus-alertmanager-0                            1/1     Running   0          59s
prometheus-kube-state-metrics-6c848bf576-h2pfn       1/1     Running   0          59s
prometheus-prometheus-node-exporter-r2wz7            1/1     Running   0          59s
prometheus-prometheus-pushgateway-665ccd8fbd-sl2xt   1/1     Running   0          59s
prometheus-server-5976cbd86f-6s8d9                   1/2     Running   0          59s
```

<br/>

```
$ kubectl get svc -n monitoring
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
prometheus-alertmanager               ClusterIP   10.106.147.122   <none>        9093/TCP       106s
prometheus-alertmanager-headless      ClusterIP   None             <none>        9093/TCP       106s
prometheus-kube-state-metrics         ClusterIP   10.96.153.15     <none>        8080/TCP       106s
prometheus-prometheus-node-exporter   ClusterIP   10.102.58.81     <none>        9100/TCP       106s
prometheus-prometheus-pushgateway     ClusterIP   10.110.114.16    <none>        9091/TCP       106s
prometheus-server                     NodePort    10.104.221.241   <none>        80:30090/TCP   106s
```

<br/>

```
$ kubectl get svc -n monitoring
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
prometheus-alertmanager               ClusterIP   10.106.147.122   <none>        9093/TCP       106s
prometheus-alertmanager-headless      ClusterIP   None             <none>        9093/TCP       106s
prometheus-kube-state-metrics         ClusterIP   10.96.153.15     <none>        8080/TCP       106s
prometheus-prometheus-node-exporter   ClusterIP   10.102.58.81     <none>        9100/TCP       106s
prometheus-prometheus-pushgateway     ClusterIP   10.110.114.16    <none>        9091/TCP       106s
prometheus-server                     NodePort    10.104.221.241   <none>        80:30090/TCP   106s
```

<br/>

```
$ minikube --profile ${PROFILE} ip
192.168.49.2
```

<br/>

```
//OK!
// Prometheus
http://192.168.49.2:30090/
```

<br/>

### Lab - Canary with Automated Analysis

https://github.com/lm-academy/argo-rollouts-course/tree/main/analysis-canary

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: analysis-lab
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: analysis-canary
  namespace: analysis-lab
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '3000'
    prometheus.io/path: '/metrics'
spec:
  ports:
    - port: 3000
      name: http
  selector:
    app: analysis-canary
---
apiVersion: v1
kind: Service
metadata:
  name: analysis-canary-stable
  namespace: analysis-lab
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '3000'
    prometheus.io/path: '/metrics'
spec:
  ports:
    - port: 3000
      name: http
  selector:
    app: analysis-canary
---
apiVersion: v1
kind: Service
metadata:
  name: analysis-canary-canary
  namespace: analysis-lab
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '3000'
    prometheus.io/path: '/metrics'
spec:
  ports:
    - port: 3000
      name: http
  selector:
    app: analysis-canary
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: analysis-canary
  namespace: analysis-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: analysis-canary
  template:
    metadata:
      labels:
        app: analysis-canary
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '3000'
        prometheus.io/path: '/metrics'
    spec:
      containers:
        - name: analysis-canary
          image: lmacademy/simple-color-app:1.1.0
          env:
            - name: ERROR_RATE
              value: '0.1'
            - name: APP_COLOR
              value: red
  strategy:
    canary:
      canaryService: analysis-canary-canary
      stableService: analysis-canary-stable
      steps:
        - setWeight: 20
        - pause:
            duration: 3m
        - analysis:
            templates:
              - templateName: success-rate
            args:
              - name: service-name
                value: analysis-canary
        - setWeight: 40
        - pause:
            duration: 10s
        - setWeight: 80
        - pause:
            duration: 10s
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
  namespace: analysis-lab
spec:
  args:
    - name: service-name
  metrics:
    - name: success-rate
      interval: 5s
      count: 60
      successCondition: result[0] >= 0.95
      failureLimit: 3
      provider:
        prometheus:
          address: http://prometheus-server.monitoring.svc.cluster.local:80
          query: |
            sum(rate(http_request_duration_seconds_count{code!~"[45].*", service="{{args.service-name}}"}[1m]))
            /
            sum(rate(http_request_duration_seconds_count{service="{{args.service-name}}"}[1m]))
EOF
```

<br/>

```
$ kubectl get pods -n analysis-lab
NAME                               READY   STATUS    RESTARTS   AGE
analysis-canary-56fc68bff9-w8h8m   1/1     Running   0          8m17s
analysis-canary-56fc68bff9-wf2v5   1/1     Running   0          8m17s
analysis-canary-56fc68bff9-wppdv   1/1     Running   0          8m17s
analysis-canary-56fc68bff9-xlsnh   1/1     Running   0          8m17s
analysis-canary-56fc68bff9-zzcjk   1/1     Running   0          8m17s
```

<br/>

```
$ kubectl get svc -n analysis-lab
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
analysis-canary          ClusterIP   10.102.20.41    <none>        3000/TCP   10m
analysis-canary-canary   ClusterIP   10.105.134.48   <none>        3000/TCP   10m
analysis-canary-stable   ClusterIP   10.111.158.63   <none>        3000/TCP   10m
```

<!-- <br/>

```
$ minikube --profile ${PROFILE} service analysis-canary -n analysis-lab --url
``` -->

<br/>

```
$ kubectl port-forward svc/analysis-canary -n analysis-lab 3000:3000
```

<br/>

```
// OK!
http://localhost:3000
```

<br/>

```
$ cd argo-rollouts-course/analysis-canary/
$ ./test-requests.sh http://localhost:3000  -1 0.2
```

```
***
---------------------------------------------------
[1] Response: Rollout Demo: red
[2] Response: Rollout Demo: red
[3] Response: Rollout Demo: red
[4] Request failed with status 503
[5] Response: Rollout Demo: red
[6] Response: Rollout Demo: red
[7] Response: Rollout Demo: red
[8] Response: Rollout Demo: red
[9] Response: Rollout Demo: red
[10] Response: Rollout Demo: red
[11] Request failed with status 503
[12] Response: Rollout Demo: red
[13] Response: Rollout Demo: red
```

<br/>

```
// OK!
http://localhost:3000/metrics
```

```
http_request_duration_seconds_count{method="GET",route="/",code="200"} 195
```

<br/>

```
// Prometheus
http://192.168.49.2:30090/
```

```
>_
http_request_duration_seconds_sum{service="analysis-canary"}


>_
http_request_duration_seconds_count{service="analysis-canary"}

>_
sum(rate(http_request_duration_seconds_count{code="503", service="analysis-canary"}[1m]))

>_
sum(rate(http_request_duration_seconds_count{code!~"[45].*", service="analysis-canary"}[1m])) / sum(rate(http_request_duration_seconds_count{service="analysis-canary"}[1m]))
```

<br/>

```
// Запуск dashboard
$ kubectl argo rollouts dashboard
```

<br/>

```
// OK!
http://localhost:3100/rollouts/analysis-lab
```

<br/>

### Lab - Blue-Green with Automated Analysis

https://github.com/lm-academy/argo-rollouts-course/tree/main/analysis-blue-green/manifests

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: analysis-lab
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: blue-green-active
  namespace: analysis-lab
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '3000'
    prometheus.io/path: '/metrics'
spec:
  ports:
    - port: 3000
      name: http
  selector:
    app: analysis-blue-green
---
apiVersion: v1
kind: Service
metadata:
  name: blue-green-preview
  namespace: analysis-lab
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '3000'
    prometheus.io/path: '/metrics'
spec:
  ports:
    - port: 3000
      name: http
  selector:
    app: analysis-blue-green
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
  namespace: analysis-lab
spec:
  args:
    - name: service-name
    - name: initial-delay
      value: 5s
    - name: success-threshold
      value: '0.95'
  metrics:
    - name: success-rate
      interval: 5s
      count: 20
      initialDelay: '{{args.initial-delay}}'
      successCondition: result[0] >= {{args.success-threshold}}
      failureLimit: 3
      provider:
        prometheus:
          address: http://prometheus-server.monitoring.svc.cluster.local:80
          query: |
            sum(rate(http_request_duration_seconds_count{code!~"[45].*", service="{{args.service-name}}"}[1m]))
            /
            sum(rate(http_request_duration_seconds_count{service="{{args.service-name}}"}[1m]))
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: analysis-blue-green
  namespace: analysis-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: analysis-blue-green
  template:
    metadata:
      labels:
        app: analysis-blue-green
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '3000'
        prometheus.io/path: '/metrics'
    spec:
      containers:
        - name: analysis-blue-green
          image: lmacademy/simple-color-app:1.1.0
          env:
            - name: ERROR_RATE
              value: '0.03'
            - name: APP_COLOR
              value: green
  strategy:
    blueGreen:
      activeService: blue-green-active
      previewService: blue-green-preview
      prePromotionAnalysis:
        templates:
          - templateName: success-rate
        args:
          - name: service-name
            value: blue-green-preview
          - name: initial-delay
            value: 2m
EOF
```

<br/>

```
// Запуск dashboard
$ kubectl argo rollouts dashboard
```

<br/>

```
// OK!
http://localhost:3100/rollouts/rollout/analysis-lab/analysis-blue-green
```

<br/>

```
$ kubectl get svc -n analysis-lab
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
blue-green-active    ClusterIP   10.101.127.133   <none>        3000/TCP   12m
blue-green-preview   ClusterIP   10.97.114.166    <none>        3000/TCP   12m
```

<br/>

```
$ kubectl port-forward svc/blue-green-active -n analysis-lab 3001:3000
$ kubectl port-forward svc/blue-green-preview -n analysis-lab 3002:3000
```

<br/>

```
$ cd argo-rollouts-course/analysis-blue-green/
$ ./test-requests.sh http://localhost:3002  -1 0.2
```

<br/>

```
// OK!
http://localhost:3000
```
