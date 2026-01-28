---
layout: page
title: Ultimate Argo Bootcamp - Automated Analysis and Experiments with Prometheus and Grafana
description: Ultimate Argo Bootcamp - Automated Analysis and Experiments with Prometheus and Grafana
keywords: courses, gitops, argo, Ultimate Argo Bootcamp, Automated Analysis and Experiments with Prometheus and Grafana
permalink: /courses/gitops/ci-cd/argo/ultimate-argo-bootcamp-by-school-of-devops/automated-analysis-and-experiments-with-prometheus-and-grafana/
---

# [School Of DevOps] Ultimate Argo Bootcamp: Automated Analysis and Experiments with Prometheus and Grafana

<br/>

Делаю:  
2026.01.23

<br/>

https://kubernetes-tutorial.schoolofdevops.com/argo_experiments_analysis/

<br/>

### [Устанавливаем metrics-server](//docs.k8s.ru/tools/containers/kubernetes/utils/metrics-server/)

<br/>

### Устанавливаем kube-prometheus-stack

```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
```

<br/>

```
$ helm upgrade --install prom -n monitoring \
  prometheus-community/kube-prometheus-stack \
  --create-namespace \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30400 \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

<br/>

```
$ kubectl get pods -n monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prom-kube-prometheus-stack-alertmanager-0   2/2     Running   0          34m
prom-grafana-588fbff6bb-ttvjw                            3/3     Running   0          34m
prom-kube-prometheus-stack-operator-fdd8bbfb9-tx8c8      1/1     Running   0          34m
prom-kube-state-metrics-7595f89c6-nj7ws                  1/1     Running   0          34m
prom-prometheus-node-exporter-sjx7t                      1/1     Running   0          34m
prometheus-prom-kube-prometheus-stack-prometheus-0       2/2     Running   0          34m
```

<br/>

```
$ kubectl -n monitoring port-forward --address 0.0.0.0 svc/prom-grafana 3000:3000 > /dev/null
```

<br/>

```
// Пароль лежал закодированный base64 в config-map prom-grafana
// admin / T26FQctUlO8F2qoBOFapa56xqC94DYfa9oFoZ66D
http://localhost:3000/login
```

<br/>

```
Dashboards -> Prometheus Overview
Dashboards -> Grafana Overview
```

<br/>

### Redeploy Nginx Ingress Controller

Пердыдущую версию удаляем.

```
$ helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=true --set \ controller.metrics.serviceMonitor.additionalLabels.release="prometheus" \
  --set controller.hostPort.enabled=true \
  --set controller.hostPort.ports.http=80 \
  --set controller.hostPort.ports.https=443 \
  --set controller.service.type=NodePort \
  --set-string controller.nodeSelector."kubernetes\.io/os"=linux \
  --set-string controller.nodeSelector.ingress-ready="true"
```

<br/>

```
$ kubectl -n monitoring port-forward --address 0.0.0.0 svc/prom-kube-prometheus-stack-prometheus 9090:9090
```

```
http://localhost:9090
```

Вводим nginx, дожно быть куча метрик с nginx_ingress_controller

<br/>

### Setup Grafana Dashboard for Nginx Ingress Controller

Setup Grafana Dashboard for Nginx Ingress Controller
Now, login to grafana and import custom dashboard for Nginx Ingress as

Left menu (hover over +) -> Dashboard
Click "Import"
Enter the copy pasted json from https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/grafana/dashboards/nginx.json
Click Import JSON
Select the Prometheus data source
Click "Import"

```
{
  "__inputs": [
    {
      "name": "DS_PROMETHEUS",
      "label": "Prometheus",
      "description": "",
      "type": "datasource",
      "pluginId": "prometheus",
      "pluginName": "Prometheus"
    }
  ],
  "__elements": {},
  "__requires": [
    {
      "type": "grafana",
      "id": "grafana",
      "name": "Grafana",
      "version": "10.4.3"
    },
    {
      "type": "panel",
      "id": "heatmap",
      "name": "Heatmap",
      "version": ""
    },
    {
      "type": "datasource",
      "id": "prometheus",
      "name": "Prometheus",
      "version": "1.0.0"
    },
    {
      "type": "panel",
      "id": "stat",
      "name": "Stat",
      "version": ""
    },
    {
      "type": "panel",
      "id": "table",
      "name": "Table",
      "version": ""
    },
    {
      "type": "panel",
      "id": "timeseries",
      "name": "Time series",
      "version": ""
    }
  ],
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "datasource",
          "uid": "grafana"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      },
      {
        "datasource": {
          "type": "prometheus",
          "uid": "${DS_PROMETHEUS}"
        },
        "enable": true,
        "expr": "sum(changes(nginx_ingress_controller_config_last_reload_successful_timestamp_seconds{instance!=\"unknown\",controller_class=~\"$controller_class\",namespace=~\"$namespace\"}[30s])) by (controller_class)",
        "hide": false,
        "iconColor": "rgba(255, 96, 96, 1)",
        "limit": 100,
        "name": "Config Reloads",
        "showIn": 0,
        "step": "30s",
        "tagKeys": "controller_class",
        "tags": [],
        "titleFormat": "Config Reloaded",
        "type": "tags"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "rgb(31, 120, 193)",
            "mode": "fixed"
          },
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "ops"
        },
        "overrides": []
      },
      "id": 20,
      "maxDataPoints": 100,
      "options": {
        "colorMode": "none",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "round(sum(irate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\"}[2m])), 0.001)",
          "format": "time_series",
          "intervalFactor": 1,
          "refId": "A",
          "step": 4
        }
      ],
      "title": "Controller Request Volume",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "rgb(31, 120, 193)",
            "mode": "fixed"
          },
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 6,
        "x": 6,
        "y": 0
      },
      "id": 82,
      "maxDataPoints": 100,
      "options": {
        "colorMode": "none",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "sum(avg_over_time(nginx_ingress_controller_nginx_process_connections{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",state=\"active\"}[2m]))",
          "format": "time_series",
          "instant": false,
          "intervalFactor": 1,
          "refId": "A",
          "step": 4
        }
      ],
      "title": "Controller Connections",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "rgb(31, 120, 193)",
            "mode": "fixed"
          },
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "rgba(245, 54, 54, 0.9)",
                "value": null
              },
              {
                "color": "rgba(237, 129, 40, 0.89)",
                "value": 95
              },
              {
                "color": "rgba(50, 172, 45, 0.97)",
                "value": 99
              }
            ]
          },
          "unit": "percentunit"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 6,
        "x": 12,
        "y": 0
      },
      "id": 21,
      "maxDataPoints": 100,
      "options": {
        "colorMode": "none",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\",status!~\"[4-5].*\"}[2m])) / sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\"}[2m]))",
          "format": "time_series",
          "intervalFactor": 1,
          "refId": "A",
          "step": 4
        }
      ],
      "title": "Controller Success Rate (non-4|5xx responses)",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "rgb(31, 120, 193)",
            "mode": "fixed"
          },
          "decimals": 0,
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 3,
        "x": 18,
        "y": 0
      },
      "id": 81,
      "maxDataPoints": 100,
      "options": {
        "colorMode": "none",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "sum"
          ],
          "fields": "",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "avg(irate(nginx_ingress_controller_success{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[1m])) * 60",
          "format": "time_series",
          "instant": false,
          "intervalFactor": 1,
          "refId": "A",
          "step": 4
        }
      ],
      "title": "Config Reloads",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "rgb(31, 120, 193)",
            "mode": "fixed"
          },
          "decimals": 0,
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 3,
        "x": 21,
        "y": 0
      },
      "id": 83,
      "maxDataPoints": 100,
      "options": {
        "colorMode": "none",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "count(nginx_ingress_controller_config_last_reload_successful{controller_pod=~\"$controller\",controller_namespace=~\"$namespace\"} == 0)",
          "format": "time_series",
          "instant": true,
          "intervalFactor": 1,
          "refId": "A",
          "step": 4
        }
      ],
      "title": "Last Config Failed",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": true,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "reqps"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byValue",
              "options": {
                "op": "gte",
                "reducer": "allIsZero",
                "value": 0
              }
            },
            "properties": [
              {
                "id": "custom.hideFrom",
                "value": {
                  "legend": true,
                  "tooltip": true,
                  "viz": false
                }
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 7,
        "w": 12,
        "x": 0,
        "y": 3
      },
      "id": 86,
      "options": {
        "legend": {
          "calcs": [
            "mean"
          ],
          "displayMode": "table",
          "placement": "right",
          "showLegend": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "pluginVersion": "10.4.3",
      "repeatDirection": "h",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "round(sum(irate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",exported_namespace=~\"$exported_namespace\",ingress=~\"$ingress\"}[2m])) by (ingress), 0.001)",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{ ingress }}",
          "metric": "network",
          "refId": "A",
          "step": 10
        }
      ],
      "title": "Ingress Request Volume",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": true,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "percentunit"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "max - istio-proxy"
            },
            "properties": [
              {
                "id": "color",
                "value": {
                  "fixedColor": "#890f02",
                  "mode": "fixed"
                }
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "max - master"
            },
            "properties": [
              {
                "id": "color",
                "value": {
                  "fixedColor": "#bf1b00",
                  "mode": "fixed"
                }
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "max - prometheus"
            },
            "properties": [
              {
                "id": "color",
                "value": {
                  "fixedColor": "#bf1b00",
                  "mode": "fixed"
                }
              }
            ]
          },
          {
            "matcher": {
              "id": "byValue",
              "options": {
                "op": "gte",
                "reducer": "allIsNull",
                "value": 0
              }
            },
            "properties": [
              {
                "id": "custom.hideFrom",
                "value": {
                  "legend": true,
                  "tooltip": true,
                  "viz": false
                }
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 7,
        "w": 12,
        "x": 12,
        "y": 3
      },
      "id": 87,
      "options": {
        "legend": {
          "calcs": [
            "mean"
          ],
          "displayMode": "table",
          "placement": "right",
          "showLegend": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "asc"
        }
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\",exported_namespace=~\"$exported_namespace\",ingress=~\"$ingress\",status!~\"[4-5].*\"}[2m])) by (ingress) / sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\",exported_namespace=~\"$exported_namespace\",ingress=~\"$ingress\"}[2m])) by (ingress)",
          "format": "time_series",
          "instant": false,
          "interval": "10s",
          "intervalFactor": 1,
          "legendFormat": "{{ ingress }}",
          "metric": "container_memory_usage:sort_desc",
          "refId": "A",
          "step": 10
        }
      ],
      "title": "Ingress Success Rate (non-4|5xx responses)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": true,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "Bps"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 6,
        "w": 8,
        "x": 0,
        "y": 10
      },
      "id": 32,
      "options": {
        "legend": {
          "calcs": [
            "mean",
            "lastNotNull"
          ],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": false,
          "width": 200
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "sum (irate (nginx_ingress_controller_request_size_sum{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[2m]))",
          "format": "time_series",
          "instant": false,
          "interval": "10s",
          "intervalFactor": 1,
          "legendFormat": "Received",
          "metric": "network",
          "refId": "A",
          "step": 10
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "- sum (irate (nginx_ingress_controller_response_size_sum{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[2m]))",
          "format": "time_series",
          "hide": false,
          "interval": "10s",
          "intervalFactor": 1,
          "legendFormat": "Sent",
          "metric": "network",
          "refId": "B",
          "step": 10
        }
      ],
      "title": "Network I/O pressure",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": true,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "bytes"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "max - istio-proxy"
            },
            "properties": [
              {
                "id": "color",
                "value": {
                  "fixedColor": "#890f02",
                  "mode": "fixed"
                }
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "max - master"
            },
            "properties": [
              {
                "id": "color",
                "value": {
                  "fixedColor": "#bf1b00",
                  "mode": "fixed"
                }
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "max - prometheus"
            },
            "properties": [
              {
                "id": "color",
                "value": {
                  "fixedColor": "#bf1b00",
                  "mode": "fixed"
                }
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 6,
        "w": 8,
        "x": 8,
        "y": 10
      },
      "id": 77,
      "options": {
        "legend": {
          "calcs": [
            "mean",
            "lastNotNull"
          ],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": false,
          "width": 200
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "avg(nginx_ingress_controller_nginx_process_resident_memory_bytes{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}) ",
          "format": "time_series",
          "instant": false,
          "interval": "10s",
          "intervalFactor": 1,
          "legendFormat": "nginx",
          "metric": "container_memory_usage:sort_desc",
          "refId": "A",
          "step": 10
        }
      ],
      "title": "Average Memory Usage",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "cores",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": true,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "line+area"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "transparent",
                "value": null
              }
            ]
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 6,
        "w": 8,
        "x": 16,
        "y": 10
      },
      "id": 79,
      "options": {
        "legend": {
          "calcs": [
            "mean",
            "lastNotNull"
          ],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": false
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "avg (rate (nginx_ingress_controller_nginx_process_cpu_seconds_total{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[2m])) ",
          "format": "time_series",
          "interval": "10s",
          "intervalFactor": 1,
          "legendFormat": "nginx",
          "metric": "container_cpu",
          "refId": "A",
          "step": 10
        }
      ],
      "title": "Average CPU Usage",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "This data is real time, independent of dashboard time range",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "custom": {
            "align": "auto",
            "cellOptions": {
              "type": "auto"
            },
            "inspect": false
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "ingress"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "Ingress"
              },
              {
                "id": "unit",
                "value": "short"
              },
              {
                "id": "decimals",
                "value": 2
              },
              {
                "id": "custom.align"
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Value #A"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "P50 Latency"
              },
              {
                "id": "unit",
                "value": "dtdurations"
              },
              {
                "id": "custom.align"
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Value #B"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "P90 Latency"
              },
              {
                "id": "unit",
                "value": "dtdurations"
              },
              {
                "id": "custom.align"
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Value #C"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "P99 Latency"
              },
              {
                "id": "unit",
                "value": "dtdurations"
              },
              {
                "id": "custom.align"
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Value #D"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "IN"
              },
              {
                "id": "unit",
                "value": "Bps"
              },
              {
                "id": "decimals",
                "value": 2
              },
              {
                "id": "custom.align"
              },
              {
                "id": "thresholds",
                "value": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "rgba(245, 54, 54, 0.9)",
                      "value": null
                    },
                    {
                      "color": "rgba(237, 129, 40, 0.89)"
                    }
                  ]
                }
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Time"
            },
            "properties": [
              {
                "id": "unit",
                "value": "short"
              },
              {
                "id": "decimals",
                "value": 2
              },
              {
                "id": "custom.align"
              },
              {
                "id": "custom.hidden",
                "value": true
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Value #E"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "OUT"
              },
              {
                "id": "unit",
                "value": "Bps"
              },
              {
                "id": "decimals",
                "value": 2
              },
              {
                "id": "custom.align"
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 8,
        "w": 24,
        "x": 0,
        "y": 16
      },
      "hideTimeOverride": false,
      "id": 75,
      "options": {
        "cellHeight": "sm",
        "footer": {
          "countRows": false,
          "fields": "",
          "reducer": [
            "sum"
          ],
          "show": false
        },
        "showHeader": true
      },
      "pluginVersion": "10.4.3",
      "repeatDirection": "h",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "histogram_quantile(0.50, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (le, ingress))",
          "format": "table",
          "hide": false,
          "instant": true,
          "intervalFactor": 1,
          "legendFormat": "{{ ingress }}",
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "histogram_quantile(0.90, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (le, ingress))",
          "format": "table",
          "hide": false,
          "instant": true,
          "intervalFactor": 1,
          "legendFormat": "{{ ingress }}",
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "histogram_quantile(0.99, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (le, ingress))",
          "format": "table",
          "hide": false,
          "instant": true,
          "intervalFactor": 1,
          "legendFormat": "{{ destination_service }}",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "sum(irate(nginx_ingress_controller_request_size_sum{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (ingress)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{ ingress }}",
          "refId": "D"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "sum(irate(nginx_ingress_controller_response_size_sum{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (ingress)",
          "format": "table",
          "instant": true,
          "intervalFactor": 1,
          "legendFormat": "{{ ingress }}",
          "refId": "E"
        }
      ],
      "title": "Ingress Percentile Response Times and Transfer Rates",
      "transformations": [
        {
          "id": "merge",
          "options": {
            "reducers": []
          }
        }
      ],
      "type": "table"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "s"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 7,
        "w": 12,
        "x": 0,
        "y": 24
      },
      "hideTimeOverride": false,
      "id": 91,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "pluginVersion": "8.3.4",
      "repeatDirection": "h",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "exemplar": true,
          "expr": "histogram_quantile(0.80, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (le))",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "P80",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "exemplar": true,
          "expr": "histogram_quantile(0.90, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (le))",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "P90",
          "refId": "D"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "editorMode": "code",
          "exemplar": true,
          "expr": "histogram_quantile(0.99, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (le))",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "P99",
          "refId": "E"
        }
      ],
      "title": "Ingress Percentile Response Times (Ingress Namespaces)",
      "type": "timeseries"
    },
    {
      "cards": {},
      "color": {
        "cardColor": "#b4ff00",
        "colorScale": "sqrt",
        "colorScheme": "interpolateWarm",
        "exponent": 0.5,
        "mode": "spectrum"
      },
      "dataFormat": "tsbuckets",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "scaleDistribution": {
              "type": "linear"
            }
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 7,
        "w": 12,
        "x": 12,
        "y": 24
      },
      "heatmap": {},
      "hideZeroBuckets": false,
      "highlightCards": true,
      "id": 89,
      "legend": {
        "show": true
      },
      "options": {
        "calculate": false,
        "calculation": {},
        "cellGap": 2,
        "cellValues": {},
        "color": {
          "exponent": 0.5,
          "fill": "#b4ff00",
          "mode": "scheme",
          "reverse": false,
          "scale": "exponential",
          "scheme": "Warm",
          "steps": 128
        },
        "exemplars": {
          "color": "rgba(255,0,255,0.7)"
        },
        "filterValues": {
          "le": 1e-9
        },
        "legend": {
          "show": true
        },
        "rowsFrame": {
          "layout": "auto"
        },
        "showValue": "never",
        "tooltip": {
          "mode": "single",
          "showColorScale": false,
          "yHistogram": true
        },
        "yAxis": {
          "axisPlacement": "left",
          "reverse": false,
          "unit": "s"
        }
      },
      "pluginVersion": "10.4.3",
      "reverseYBuckets": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "exemplar": true,
          "expr": "sum(increase(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\",exported_namespace=~\"$exported_namespace\"}[2m])) by (le)",
          "format": "heatmap",
          "interval": "",
          "legendFormat": "{{le}}",
          "refId": "A"
        }
      ],
      "title": "Ingress Request Latency Heatmap (Ingress Namespaces)",
      "tooltip": {
        "show": true,
        "showHistogram": true
      },
      "type": "heatmap",
      "xAxis": {
        "show": true
      },
      "yAxis": {
        "format": "s",
        "logBase": 1,
        "show": true
      },
      "yBucketBound": "auto"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "custom": {
            "align": "auto",
            "cellOptions": {
              "type": "auto"
            },
            "inspect": false
          },
          "decimals": 2,
          "displayName": "",
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "short"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "Last *"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "TTL"
              },
              {
                "id": "unit",
                "value": "s"
              },
              {
                "id": "custom.cellOptions",
                "value": {
                  "type": "color-background"
                }
              },
              {
                "id": "thresholds",
                "value": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "rgba(245, 54, 54, 0.9)",
                      "value": null
                    },
                    {
                      "color": "rgba(237, 129, 40, 0.89)",
                      "value": 0
                    },
                    {
                      "color": "rgba(50, 172, 45, 0.97)",
                      "value": 691200
                    }
                  ]
                }
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Field"
            },
            "properties": [
              {
                "id": "displayName",
                "value": "Host"
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 8,
        "w": 24,
        "x": 0,
        "y": 31
      },
      "id": 85,
      "options": {
        "cellHeight": "sm",
        "footer": {
          "countRows": false,
          "enablePagination": false,
          "fields": "",
          "reducer": [
            "sum"
          ],
          "show": false
        },
        "showHeader": true
      },
      "pluginVersion": "10.4.3",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "avg(nginx_ingress_controller_ssl_expire_time_seconds{kubernetes_pod_name=~\"$controller\",namespace=~\"$namespace\",ingress=~\"$ingress\"}) by (host) - time()",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "{{ host }}",
          "metric": "gke_letsencrypt_cert_expiration",
          "refId": "A",
          "step": 1
        }
      ],
      "title": "Ingress Certificate Expiry",
      "transformations": [
        {
          "id": "reduce",
          "options": {
            "includeTimeField": false,
            "labelsToFields": false,
            "reducers": [
              "lastNotNull"
            ]
          }
        }
      ],
      "type": "table"
    }
  ],
  "refresh": "5s",
  "schemaVersion": 39,
  "tags": [
    "nginx"
  ],
  "templating": {
    "list": [
      {
        "current": {
          "selected": false,
          "text": "Prometheus",
          "value": "${DS_PROMETHEUS}"
        },
        "hide": 0,
        "includeAll": false,
        "label": "datasource",
        "multi": false,
        "name": "DS_PROMETHEUS",
        "options": [],
        "query": "prometheus",
        "queryValue": "",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "type": "datasource"
      },
      {
        "allValue": ".*",
        "current": {},
        "datasource": {
          "type": "prometheus",
          "uid": "${DS_PROMETHEUS}"
        },
        "definition": "",
        "hide": 0,
        "includeAll": true,
        "label": "Namespace",
        "multi": false,
        "name": "namespace",
        "options": [],
        "query": "label_values(nginx_ingress_controller_config_hash, controller_namespace)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 0,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allValue": ".*",
        "current": {},
        "datasource": {
          "type": "prometheus",
          "uid": "${DS_PROMETHEUS}"
        },
        "definition": "",
        "hide": 0,
        "includeAll": true,
        "label": "Controller Class",
        "multi": false,
        "name": "controller_class",
        "options": [],
        "query": "label_values(nginx_ingress_controller_config_hash{namespace=~\"$namespace\"}, controller_class) ",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 0,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allValue": ".*",
        "current": {},
        "datasource": {
          "type": "prometheus",
          "uid": "${DS_PROMETHEUS}"
        },
        "definition": "",
        "hide": 0,
        "includeAll": true,
        "label": "Controller",
        "multi": false,
        "name": "controller",
        "options": [],
        "query": "label_values(nginx_ingress_controller_config_hash{namespace=~\"$namespace\",controller_class=~\"$controller_class\"}, controller_pod) ",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 1,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allValue": ".*",
        "current": {},
        "datasource": {
          "type": "prometheus",
          "uid": "${DS_PROMETHEUS}"
        },
        "definition": "",
        "hide": 0,
        "includeAll": true,
        "label": "Ingress Namespace",
        "multi": false,
        "name": "exported_namespace",
        "options": [],
        "query": "label_values(nginx_ingress_controller_requests{namespace=~\"$namespace\",controller_class=~\"$controller_class\",controller_pod=~\"$controller\"}, exported_namespace) ",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 1,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allValue": ".*",
        "current": {},
        "datasource": {
          "type": "prometheus",
          "uid": "${DS_PROMETHEUS}"
        },
        "definition": "",
        "hide": 0,
        "includeAll": true,
        "label": "Ingress",
        "multi": false,
        "name": "ingress",
        "options": [],
        "query": "label_values(nginx_ingress_controller_requests{namespace=~\"$namespace\",controller_class=~\"$controller_class\",controller_pod=~\"$controller\",exported_namespace=~\"$exported_namespace\"}, ingress) ",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 1,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      }
    ]
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "2m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "timezone": "browser",
  "title": "NGINX Ingress controller",
  "uid": "nginx",
  "version": 1,
  "weekStart": ""
}
```

<br/>

```
$ sudo vi /etc/hosts

127.0.0.1 vote.example.com
```

<br/>

```
// OK!
http://vote.example.com
```

<br/>

### Updated Rollout Configuration with Experiment and Analysis

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: vote
spec:
  replicas: 5
  strategy:
    blueGreen: null
    canary:
      canaryService: vote-preview
      stableService: vote
      steps:
      - setCanaryScale:
          replicas: 2
      - experiment:
          duration: 3m
          templates:
          - name: canary
            specRef: canary
            service:
              name: experiment
          analyses:
            - name: fitness-test
              templateName: canary-fitness-test
      - setWeight: 20
      - pause:
          duration: 10s
      - setWeight: 40
      - pause:
          duration: 10s
      - setWeight: 60
      - analysis:
          templates:
          - templateName: loadtest
          - templateName: latency
      - setWeight: 80
      - pause:
          duration: 10s
      - setWeight: 100
      trafficRouting:
        nginx:
          stableIngress: vote
          additionalIngressAnnotations:
            canary-by-header: X-Canary
            canary-by-header-value: siege
EOF
```

<br/>

### Template for Load Testing

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: loadtest
spec:
  metrics:
  - name: loadtest-vote
    provider:
      job:
        spec:
          template:
            spec:
              containers:
              - name: siege
                image: schoolofdevops/loadtest:v1
                command:
                  - siege
                  - "--concurrent=2"
                  - "--benchmark"
                  - "--time=5m"
                  - "--header='X-Canary: siege'"
                  - "http://vote.example.com"
              restartPolicy: Never
              hostAliases:
              - ip: "xx.xx.xx.xx"
                hostnames:
                - "vote.example.com"
          backoffLimit: 4
EOF
```

<br/>

```
$ kubectl get nodes -o wide
```

Заменить xx.xx.xx.xx

<br/>

### AnalysisTemplate for Prometheus Metrics

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: latency
spec:
  metrics:
  - name: nginx-latency-ms
    initialDelay: 1m
    interval: 1m
    failureLimit: 2
    count: 4
    successCondition: result < 50.0
    failureCondition: result >= 50.0
    provider:
      prometheus:
        address: http://prom-kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090
        query: |
          scalar(
            1000 * histogram_quantile(0.99,
              sum(
                rate(
                  nginx_ingress_controller_request_duration_seconds_bucket{ingress="vote", exported_namespace="prod"}[1m]
                )
              ) by (le)
            )
          )
EOF
```

<br/>

### Fitness Test for Canary

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: canary-fitness-test
spec:
  metrics:
  - name: canary-fitness
    interval: 30s
    count: 3
    successCondition: result == "true"
    failureLimit: 1
    provider:
      job:
        spec:
          template:
            spec:
              containers:
              - name: fitness-test
                image: curlimages/curl
                command: ["/bin/sh", "-c"]
                args:
                - |
                  FITNESS_RESULT="false"
                  CANARY_SERVICE_URL="http://vote-preview"

                  # Perform the fitness test
                  RESPONSE=$(curl -s $CANARY_SERVICE_URL)

                  # Check if the response contains the expected string
                  if [[ "$RESPONSE" == *"Processed by container ID"* ]]; then
                    FITNESS_RESULT="true"
                  fi

                  # Return the fitness test result
                  echo $FITNESS_RESULT
              restartPolicy: Never
          backoffLimit: 1
EOF
```
