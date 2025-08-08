---
layout: page
title: Инсталляция инструментов логирования Elastic - Elasticsearch, Kibana, Fluentd
description: Инсталляция инструментов логирования Elastic - Elasticsearch, Kibana, Fluentd
keywords: gitops, containers, logging, elastic search, kibana, fluentd
permalink: /tools/containers/kubernetes/utils/logging/elastic/setup/
---

# Инсталляция инструментов логирования Elastic - Elasticsearch, Kibana, Fluentd

<br/>

Делаю:  
2024.04.14

<br/>

### Предустановки

```
// In order to properly support the required persistent volume claims for the Elasticsearch StatefulSet, the default-storageclass and storage-provisioner minikube addons must be enabled.
$ minikube --profile ${PROFILE} addons enable default-storageclass
$ minikube --profile ${PROFILE} addons enable storage-provisioner
```

<br/>

### Качаем манифесты

```
$ cd ~/tmp
$ git clone https://github.com/wildmakaka/efk7-setup
$ cd efk7-setup
```

<br/>

```
$ kubectl create namespace logging
```

<br/>

### Elasticsearch

<br/>

```
$ cd elasticsearch
$ kubectl create -f statefulset.yaml
$ kubectl create -f service.yaml
```

<br/>

```
$ kubectl get pods -n logging
NAME           READY   STATUS    RESTARTS   AGE
es-cluster-0   1/1     Running   0          78s
es-cluster-1   1/1     Running   0          26s
es-cluster-2   1/1     Running   0          15s

```

<br/>

```
$ kubectl port-forward svc/elasticsearch 9200 -n logging
```

<br/>

```json
// Получить инфу по elastic
$ curl http://localhost:9200
{
  "name" : "es-cluster-0",
  "cluster_name" : "k8s-logs",
  "cluster_uuid" : "v8O0rwX2QfS25HtG7HH-aA",
  "version" : {
    "number" : "7.17.20",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "b26557f585b7d95c71a5549e571a6bcd2667697d",
    "build_date" : "2024-04-08T08:34:31.070382898Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.3",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

<br/>

```json
// Получить инфу по статусу работы elastic
$ curl localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "k8s-logs",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 3,
  "active_shards" : 3,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 3,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

<br/>

### Kibana

```
$ cd kibana
$ kubectl create -f deployment.yaml
// $ kubectl create -f service.yaml
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kibana-cluster-ip
  namespace: logging
spec:
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 5601
  selector:
    app: kibana
EOF
```

<br/>

```
$ kubectl port-forward svc/kibana-cluster-ip 8080 -n logging
// $ kubectl port-forward svc/kibana 8080
```

<br/>

```
// [OK!]
localhost:8080
```

<br/>

```
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo ${INGRESS_HOST}
192.168.49.2
```

<br/>

```yaml
$ envsubst << 'EOF' | cat | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kibana-ingress
  namespace: logging
  annotations:
    nginx.ingress.kubernetes.io/default-backend: ingress-nginx-controller
    kubernetes.io/ingress.class: nginx
    ## tells ingress to check for regex in the config file
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - host: ${INGRESS_HOST}.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kibana-cluster-ip
            port:
              number: 8080
EOF
```

<br/>

```
$ kubectl get ingress -n logging
NAME             CLASS    HOSTS                 ADDRESS        PORTS   AGE
kibana-ingress   <none>   192.168.49.2.nip.io   192.168.49.2   80      35s
```

<br/>

```
$ echo ${INGRESS_HOST}.nip.io
```

<br/>

```
// [OK!]
http://192.168.49.2.nip.io/
```

<br/>

```
// Удалить, если не нужен
// $ kubectl delete ingress kibana-ingress
```

<br/>

Можно попробовать вместо kibana-cluster-ip настроить externalName

https://github.com/webmakaka/docs.gitops.ru/blob/febabfe6f2f6559f2319feed5760063a82ac4fc6/website/02-courses/01-containers/01-kubernetes/01-tools/03-logging/01-efk/01-logging-in-kubernetes-with-efk-stack/04-other.md

<br/>

### Fluentd

[Взять здесь](/tools/containers/kubernetes/utils/logging/elastic/setup/helm/)
