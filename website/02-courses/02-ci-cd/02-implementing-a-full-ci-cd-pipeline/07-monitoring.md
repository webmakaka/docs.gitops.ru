---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Мониторинг
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Мониторинг
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Мониторинг
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/monitoring/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 08. Мониторинг

<br/>

Запускаю [локальный kubernetes кластер](https://github.com/webmakaka/vagrant-kubernetes-3-node-cluster-centos7)

<br/>

    $ kubectl get nodes
    NAME         STATUS   ROLES                  AGE   VERSION
    master.k8s   Ready    control-plane,master   39h   v1.20.1
    node1.k8s    Ready    <none>                 39h   v1.20.1
    node2.k8s    Ready    <none>                 39h   v1.20.1

<br/>

Устанавливаю [Helm3](//docs.k8s.ru/tools/containers/kubernetes/utils/helm/setup/) на localhost.

<br/>

    $ mkdir ~/kubernetes-configs && cd ~/kubernetes-configs

<br/>

### 01. Prometheus

    $ vi prometheus-values.yml

```
alertmanager:
  persistentVolume:
    enabled: false
server:
  persistentVolume:
    enabled: false
```

<br/>

    $ helm search repo prometheus

<br/>

    $ kubectl create namespace prometheus

    $ helm install prometheus \
      -f prometheus-values.yml \
      stable/prometheus \
      --namespace prometheus

    $ kubectl get pods -n prometheus

<br/>

    $ helm list -n prometheus
    NAME      	NAMESPACE 	REVISION	UPDATED                               	STATUS  	CHART             	APP VERSION
    prometheus	prometheus	1       	2021-01-12 15:11:13.92312402 +0300 MSK	deployed	prometheus-11.12.1	2.20.1

<br/>

### 02. Grafana

    $ vi grafana-values.yml

```
adminPassword: password
```

<br/>

    $ kubectl create namespace grafana

    $ helm install grafana \
      -f grafana-values.yml \
      stable/grafana \
      --namespace grafana

<br/>

    $ export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")

    $ kubectl --namespace prometheus port-forward $POD_NAME 9090

http://localhost:9090/graph

<br/>

    $ kubectl port-forward --namespace grafana service/grafana 3000:80

<br/>

http://localhost:3000/

<br/>

Add data source - Prometheus

Name: Prometheus

URL: http://prometheus-server.prometheus.svc.cluster.local

Save and test

<br/>

### Мониторинг кластера

http://grafana.com/dashboards/3131

Grafana -> + -> Import -> 3131

<br/>

### Мониторинг приложений

Разворачиваем приложение как в прошлый раз:

https://github.com/linuxacademy/cicd-pipeline-train-schedule-monitoring

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: train-schedule-service
  annotations:
    prometheus.io/scrape: 'true'
spec:
  type: NodePort
  selector:
    app: train-schedule
  ports:
  - protocol: TCP
    port: 8080
    nodePort: 30002

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: train-schedule-deployment
  labels:
    app: train-schedule
spec:
  replicas: 2
  selector:
    matchLabels:
      app: train-schedule
  template:
    metadata:
      labels:
        app: train-schedule
    spec:
      containers:
      - name: train-schedule
        image: linuxacademycontent/train-schedule:1
        ports:
        - containerPort: 8080
EOF
```

<br/>

http://node1.k8s:30002/

<br/>

http://node1.k8s:30002/metrics

Метрики работают!

<br/>

Grafana -> + -> Create -> Dashboard

```
sum(rate(http_request_duration_ms_count[2m])) by (service, route, method,code) * 60
```

<br/>

![Kubeconfig](/img/courses/ci-cd/implementing-a-full-ci-cd-pipeline/pic-m07-pic01.png 'Kubeconfig'){: .center-image }

<br/>

Для алертов отдельная вкладка.

<br/>

**Документация Grafana по оповещениям:**

http://docs.grafana.org/alerting/rules/​

<br/>

### Удаляю созданные ресурсы

    $ kubectl delete svc train-schedule-service
    $ kubectl delete deployment train-schedule-deployment
