---
layout: page
title: Logging in Kubernetes with EFK Stack | The Complete Guide
description: Logging in Kubernetes with EFK Stack | The Complete Guide
keywords: courses, containers, kubernetes, tools, logging, elastic, fluentd, kibana
permalink: /courses/containers/kubernetes/tools/logging/efk/logging-in-kubernetes-with-efk-stack/fluentd/
---

# [Nana Janashia] Logging in Kubernetes with EFK Stack : Настройка Fluentd

<br/>

Делаю:  
2024.04.14

<br/>

# Проверка, что Fluentd получает логи

<br/>

```
$ kubectl get pods -n logging
$ kubectl logs fluentd-p9bd9 -n logging | grep node-app
$ kubectl logs fluentd-p9bd9 -n logging | grep java-app
```

<br/>

```
Подключился к pod

$ cd /var/log/containers/

Лежат логи
```

<br/>

# Настройка Fluentd

```
$ kubectl describe configmap fluentd-forwarder-cm > ~/tmp/fluentd-forwarder-cm.backup.txt -n logging
$ kubectl edit configmap fluentd-forwarder-cm -n logging
```

<br/>

```yaml
***
data:
  fluentd.conf: |

    # Ignore fluentd own events
    <match fluent.**>
        @type null
    </match>

    # HTTP input for the liveness and readiness probes
    <source>
        @type http
        port 9880
    </source>

    # Throw the healthcheck to the standard output instead of forwarding it
    <match fluentd.healthcheck>
        @type null
    </match>

    # Get the logs from the containers running in the node
    <source>
      @type tail
      path /var/log/containers/*-app*.log
      pos_file /opt/bitnami/fluentd/logs/buffers/fluentd-docker.pos
      tag kubernetes.*
      read_from_head true
      format json
      time_format %Y-%m-%dT%H:%M:%S.%NZ
    </source>

    <filter **>
      @type parser
      key_name log
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          keep_time_key true
        </pattern>
      </parse>
    </filter>

    <filter kubernetes.**>
        @type kubernetes_metadata
    </filter>

    <match kubernetes.var.log.containers.**java-app**.log>
      @type elasticsearch
      include_tag_key true
      host "elasticsearch.logging.svc.cluster.local"
      port "9200"
      index_name "java-app-logs"
      <buffer>
        @type file
        path /opt/bitnami/fluentd/logs/buffers/java-logs.buffer
        flush_thread_count 2
        flush_interval 5s
      </buffer>
    </match>

    <match kubernetes.var.log.containers.**node-app**.log>
      @type elasticsearch
      include_tag_key true
      host "elasticsearch.logging.svc.cluster.local"
      port "9200"
      index_name "node-app-logs"
      <buffer>
        @type file
        path /opt/bitnami/fluentd/logs/buffers/node-logs.buffer
        flush_thread_count 2
        flush_interval 5s
      </buffer>
    </match>
```

<br/>

```
// Рестарт
$ kubectl rollout restart daemonset/fluentd -n logging
```

<br/>

Kibana (http://192.168.49.2.nip.io/) ->

Menu -> Analytics -> Discover

Data -> Index Management

Должны быть: node-app-logs и java-app-logs

<br/>

Kibana -> Index Patterns -> Create index pattern

<br/>

```
Index pattern name -> java-app-logs -> Next step
Index pattern name -> node-app-logs -> Next step
```

<br/>

Timestamp field -> time

Create index pattern

<br/>

Menu -> Analytics -> Discover

<br/>

Перестартовал pod.  
Логи появислись!
