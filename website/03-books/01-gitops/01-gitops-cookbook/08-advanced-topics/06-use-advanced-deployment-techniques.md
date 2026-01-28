---
layout: page
title: GitOps Cookbook - Advanced Topics - Use Advanced Deployment Techniques
description: При деплое использовать blue-green или canary
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Use Advanced Deployment Techniques
permalink: /books/gitops/gitops-cookbook/advanced-topics/use-advanced-deployment-techniques/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 08. Advanced Topics: 8.6 Use Advanced Deployment Techniques

<br/>

**Задача:**  
При деплое использовать blue-green или canary

<br/>

**Делаю:**  
2025.12.10

<br/>

Устанавливаю [argo-rollouts](/tools/gitops/ci-cd/argo/argo-rollouts/setup/)

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: bgd-rollouts
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {}
      - setWeight: 40
      - pause:
          duration: 30s
      - setWeight: 60
      - pause:
          duration: 30s
      - setWeight: 80
      - pause:
          duration: 30s
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: bgd-rollouts
  template:
    metadata:
      labels:
        app: bgd-rollouts
    spec:
      containers:
      - image: quay.io/rhdevelopers/bgd:1.0.0
        name: bgd
        env:
        - name: COLOR
          value: "blue"
        resources: {}
EOF
```

<br/>

```
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
bgd-rollouts-679cdfcfd-279mg   1/1     Running   0          27s
bgd-rollouts-679cdfcfd-drl5z   1/1     Running   0          27s
bgd-rollouts-679cdfcfd-fsjml   1/1     Running   0          27s
bgd-rollouts-679cdfcfd-m4m9n   1/1     Running   0          27s
bgd-rollouts-679cdfcfd-pffjd   1/1     Running   0          27s

```

<br/>

```
$ kubectl argo rollouts get rollout bgd-rollouts
```

<br/>

```
...
name: bgd
env:
- name: COLOR
value: "green"
resources: {}
```

<br/>

```
$ kubectl get pods
```

<br/>

```
$ kubectl argo rollouts get rollout bgd-rollouts
Name:            bgd-rollouts
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          8/8
  SetWeight:     100
  ActualWeight:  100
Images:          quay.io/rhdevelopers/bgd:1.0.0 (stable)
Replicas:
  Desired:       5
  Current:       5
  Updated:       5
  Ready:         5
  Available:     5

NAME                                     KIND        STATUS     AGE  INFO
⟳ bgd-rollouts                           Rollout     ✔ Healthy  71s
└──# revision:1
   └──⧉ bgd-rollouts-679cdfcfd           ReplicaSet  ✔ Healthy  71s  stable
      ├──□ bgd-rollouts-679cdfcfd-279mg  Pod         ✔ Running  71s  ready:1/1
      ├──□ bgd-rollouts-679cdfcfd-drl5z  Pod         ✔ Running  71s  ready:1/1
      ├──□ bgd-rollouts-679cdfcfd-fsjml  Pod         ✔ Running  71s  ready:1/1
      ├──□ bgd-rollouts-679cdfcfd-m4m9n  Pod         ✔ Running  71s  ready:1/1
      └──□ bgd-rollouts-679cdfcfd-pffjd  Pod         ✔ Running  71s  ready:1/1
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: bgd-rollouts
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {}
      - setWeight: 40
      - pause:
          duration: 30s
      - setWeight: 60
      - pause:
          duration: 30s
      - setWeight: 80
      - pause:
          duration: 30s
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: bgd-rollouts
  template:
    metadata:
      labels:
        app: bgd-rollouts
    spec:
      containers:
      - image: quay.io/rhdevelopers/bgd:1.0.0
        name: bgd
        env:
        - name: COLOR
          value: "green"
        resources: {}
EOF
```

<br/>

```
// 1 pod пошел обновляться
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
bgd-rollouts-679cdfcfd-279mg   1/1     Running   0          4m30s
bgd-rollouts-679cdfcfd-drl5z   1/1     Running   0          4m30s
bgd-rollouts-679cdfcfd-fsjml   1/1     Running   0          4m30s
bgd-rollouts-679cdfcfd-pffjd   1/1     Running   0          4m30s
bgd-rollouts-c5495c6ff-6nfwq   1/1     Running   0          19s
```

<br/>

```
$ kubectl argo rollouts get rollout bgd-rollouts
Name:            bgd-rollouts
Namespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/8
  SetWeight:     20
  ActualWeight:  20
Images:          quay.io/rhdevelopers/bgd:1.0.0 (canary, stable)
Replicas:
  Desired:       5
  Current:       5
  Updated:       1
  Ready:         5
  Available:     5

NAME                                     KIND        STATUS     AGE    INFO
⟳ bgd-rollouts                           Rollout     ॥ Paused   5m23s
├──# revision:2
│  └──⧉ bgd-rollouts-c5495c6ff           ReplicaSet  ✔ Healthy  72s    canary
│     └──□ bgd-rollouts-c5495c6ff-6nfwq  Pod         ✔ Running  72s    ready:1/1
└──# revision:1
   └──⧉ bgd-rollouts-679cdfcfd           ReplicaSet  ✔ Healthy  5m23s  stable
      ├──□ bgd-rollouts-679cdfcfd-279mg  Pod         ✔ Running  5m23s  ready:1/1
      ├──□ bgd-rollouts-679cdfcfd-drl5z  Pod         ✔ Running  5m23s  ready:1/1
      ├──□ bgd-rollouts-679cdfcfd-fsjml  Pod         ✔ Running  5m23s  ready:1/1
      └──□ bgd-rollouts-679cdfcfd-pffjd  Pod         ✔ Running  5m23s  ready:1/1
```

<br/>

```
// Подтверждаем руками обновление
$ kubectl argo rollouts promote bgd-rollouts
```

<br/>

```
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
bgd-rollouts-c5495c6ff-5tjnw   1/1     Running   0          31s
bgd-rollouts-c5495c6ff-6nfwq   1/1     Running   0          3m11s
bgd-rollouts-c5495c6ff-mxjpc   1/1     Running   0          63s
bgd-rollouts-c5495c6ff-qxzsj   1/1     Running   0          18s
bgd-rollouts-c5495c6ff-rsx8n   1/1     Running   0          11s
```

<br/>

```
$ kubectl argo rollouts get rollout bgd-rollouts
Name:            bgd-rollouts
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          8/8
  SetWeight:     100
  ActualWeight:  100
Images:          quay.io/rhdevelopers/bgd:1.0.0 (stable)
Replicas:
  Desired:       5
  Current:       5
  Updated:       5
  Ready:         5
  Available:     5

NAME                                     KIND        STATUS        AGE    INFO
⟳ bgd-rollouts                           Rollout     ✔ Healthy     7m51s
├──# revision:2
│  └──⧉ bgd-rollouts-c5495c6ff           ReplicaSet  ✔ Healthy     3m40s  stable
│     ├──□ bgd-rollouts-c5495c6ff-6nfwq  Pod         ✔ Running     3m40s  ready:1/1
│     ├──□ bgd-rollouts-c5495c6ff-mxjpc  Pod         ✔ Running     92s    ready:1/1
│     ├──□ bgd-rollouts-c5495c6ff-5tjnw  Pod         ✔ Running     60s    ready:1/1
│     ├──□ bgd-rollouts-c5495c6ff-qxzsj  Pod         ✔ Running     47s    ready:1/1
│     └──□ bgd-rollouts-c5495c6ff-rsx8n  Pod         ✔ Running     40s    ready:1/1
└──# revision:1
   └──⧉ bgd-rollouts-679cdfcfd           ReplicaSet  • ScaledDown  7m51s
```

<br/>

```
$ kubectl get rollout
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
bgd-rollouts   5         5         5            5           13m
```

<br/>

```
$ kubectl delete rollout bgd-rollouts
rollout.argoproj.io "bgd-rollouts" deleted
```

<br/>

### Пример с ISTIO

Устанавливаю [argo-rollouts](//docs.k8s.ru/tools/containers/kubernetes/utils/service-mesh/istio/setup/)

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: bgdapp
  labels:
    app: bgdapp
spec:
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause:
          duration: "1m"
      - setWeight: 50
      - pause:
          duration: "2m"
      canaryService: bgd-canary
      stableService: bgd
      trafficRouting:
        istio:
          virtualService:
            name: bgd
            routes:
            - primary
  replicas: 1
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: bgdapp
      version: v1
  template:
    metadata:
      labels:
        app: bgdapp
        version: v1
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - image: quay.io/rhdevelopers/bgd:1.0.0
        name: bgd
        env:
        - name: COLOR
          value: "blue"
        resources: {}
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: bgd
  labels:
    app: bgdapp
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: bgdapp
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: bgd-canary
  labels:
    app: bgdapp
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: bgdapp
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: bgd
spec:
  hosts:
  - bgd
  http:
  - route:
    - destination:
        host: bgd
      weight: 100
    - destination:
        host: bgd-canary
      weight: 0
    name: primary
EOF
```

<br/>

```
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
bgdapp-5cf67bf7f6-stdb9   1/1     Running   0          83s
```

<br/>

```
$ kubectl argo rollouts get rollout bgdapp
Name:            bgdapp
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          4/4
  SetWeight:     100
  ActualWeight:  100
Images:          quay.io/rhdevelopers/bgd:1.0.0 (stable)
Replicas:
  Desired:       1
  Current:       1
  Updated:       1
  Ready:         1
  Available:     1

NAME                                KIND        STATUS     AGE    INFO
⟳ bgdapp                            Rollout     ✔ Healthy  19m
└──# revision:1
   └──⧉ bgdapp-5cf67bf7f6           ReplicaSet  ✔ Healthy  2m36s  stable
      └──□ bgdapp-5cf67bf7f6-stdb9  Pod         ✔ Running  2m26s  ready:1/1
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: bgdapp
  labels:
    app: bgdapp
spec:
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause:
          duration: "1m"
      - setWeight: 50
      - pause:
          duration: "2m"
      canaryService: bgd-canary
      stableService: bgd
      trafficRouting:
        istio:
          virtualService:
            name: bgd
            routes:
            - primary
  replicas: 1
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: bgdapp
      version: v1
  template:
    metadata:
      labels:
        app: bgdapp
        version: v1
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - image: quay.io/rhdevelopers/bgd:1.0.0
        name: bgd
        env:
        - name: COLOR
          value: "red"
        resources: {}
EOF
```

<br/>

```
$ kubectl argo rollouts get rollout bgdapp
Name:            bgdapp
Namespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/4
  SetWeight:     20
  ActualWeight:  20
Images:          quay.io/rhdevelopers/bgd:1.0.0 (canary, stable)
Replicas:
  Desired:       1
  Current:       2
  Updated:       1
  Ready:         2
  Available:     2

NAME                                KIND        STATUS     AGE    INFO
⟳ bgdapp                            Rollout     ॥ Paused   24m
├──# revision:2
│  └──⧉ bgdapp-6f556fdfcc           ReplicaSet  ✔ Healthy  14s    canary
│     └──□ bgdapp-6f556fdfcc-cgnmn  Pod         ✔ Running  14s    ready:1/1
└──# revision:1
   └──⧉ bgdapp-5cf67bf7f6           ReplicaSet  ✔ Healthy  8m2s   stable
      └──□ bgdapp-5cf67bf7f6-stdb9  Pod         ✔ Running  7m52s  ready:1/1

```

<br/>

```
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
bgdapp-5cf67bf7f6-stdb9   1/1     Running   0          8m35s
bgdapp-6f556fdfcc-cgnmn   1/1     Running   0          57s
```

<br/>

```
// Подтверждаем руками обновление
$ kubectl argo rollouts promote bgdapp
```

<br/>

```
$ kubectl argo rollouts promote bgdapp
rollout 'bgdapp' promoted
```

<br/>

```
$ kubectl argo rollouts get rollout bgdapp
Name:            bgdapp
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          4/4
  SetWeight:     100
  ActualWeight:  100
Images:          quay.io/rhdevelopers/bgd:1.0.0 (stable)
Replicas:
  Desired:       1
  Current:       2
  Updated:       1
  Ready:         2
  Available:     2

NAME                                KIND        STATUS     AGE    INFO
⟳ bgdapp                            Rollout     ✔ Healthy  26m
├──# revision:2
│  └──⧉ bgdapp-6f556fdfcc           ReplicaSet  ✔ Healthy  101s   stable
│     └──□ bgdapp-6f556fdfcc-cgnmn  Pod         ✔ Running  101s   ready:1/1
└──# revision:1
   └──⧉ bgdapp-5cf67bf7f6           ReplicaSet  ✔ Healthy  9m29s  delay:27s
      └──□ bgdapp-5cf67bf7f6-stdb9  Pod         ✔ Running  9m19s  ready:1/1
```

<br/>

```
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
bgdapp-6f556fdfcc-cgnmn   1/1     Running   0          2m41s
```
