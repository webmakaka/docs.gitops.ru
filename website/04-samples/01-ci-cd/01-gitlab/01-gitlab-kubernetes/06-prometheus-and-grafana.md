---
layout: page
title: 06. Prometheus & Grafana
description: 06. Prometheus & Grafana
keywords: devops, ci-cd, gitlab, kubernetes, docker, prometheus, grafana
permalink: /samples/ci-cd/gitlab/kubernetes/prometheus-and-grafana/
---

# 06. Prometheus & Grafana

<br/>

### [Запуск Prometheus (мониторинг) и Grafana (визуализация) в kuberntes cluster с помощью heml](//docs.k8s.ru/devops/containers/kubernetes/monitoring/prometheus-and-grafana-test-only/)

<br/>

Добился, чтобы node.js приложение (backend) возвращало метрики.

<br/>

```
$ curl backend.minikube.local/metrics
# HELP process_cpu_user_seconds_total Total user CPU time spent in seconds.
# TYPE process_cpu_user_seconds_total counter
process_cpu_user_seconds_total{app="prometheus-nodejs-app"} 0.8757879999999999

# HELP process_cpu_system_seconds_total Total system CPU time spent in seconds.
# TYPE process_cpu_system_seconds_total counter
process_cpu_system_seconds_total{app="prometheus-nodejs-app"} 0.291205

# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total{app="prometheus-nodejs-app"} 1.166993
```

<br/>

http://backend.minikube.local/metrics/

<br/>

**В HelmChart добавить http-metrics**

<br/>

```
name: http-metrics
```

<br/>

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: backend
spec:
  ports:
    - name: http-metrics
      protocol: 'TCP'
      port: 80
      targetPort: 3000
  selector:
    app: backend
```

<br/>

**Создать ServiceMonitor**

```yaml
$ cat << 'EOF' | kubectl --namespace monitoring apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
    name: backend-service-monitor
spec:
    selector:
        matchLabels:
          app: backend
    namespaceSelector:
      matchNames:
      - default
    endpoints:
    - port: http-metrics
      interval: 15s
    jobLabel: backend
EOF
```

<br/>

```
$ kubectl --namespace monitoring get ServiceMonitor
NAME                                                 AGE
backend-service-monitor                              30s
```

<br/>

http://localhost:9090/config

<br/>

Появился backend-service-monitor

<br/>

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture04-pic01.png?raw=true)

<br/>

И в Targets

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture04-pic02.png?raw=true)

<br/>

Конфигурация Prometheus обновляется каждые три минуты.

Применилось ли обновление можно посмотреть командой:

```
// Не работает
$ kubectl --namespace monitoring logs prometheus-stack-kube-prom-operator-56c4476bdd-5j2tm prometheus-config-reloader
```

<br/>

```
$ kubectl describe endpoints backend
Name:         backend
Namespace:    default
Labels:       app=backend
              app.kubernetes.io/managed-by=skaffold
              skaffold.dev/run-id=52e10050-87b3-4d0d-8cc1-66fc5d657b24
Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2021-02-09T16:42:06Z
Subsets:
  Addresses:          172.17.0.13
  NotReadyAddresses:  <none>
  Ports:
    Name          Port  Protocol
    ----          ----  --------
    http-metrics  3000  TCP

Events:  <none>
```

<br/>

**Для визуализации предлагают применить dashboard-configmap.yaml**

<br/>

https://gist.githubusercontent.com/vitkhab/02af337e83e66f33903f0320938135f0/raw/73b6c177be97b89e0749bb5ed122b452da094997/reddit-dashboard-configmap.yml

<br/>

Должен появиться в Grafana dashboard Reddit Monitoring
