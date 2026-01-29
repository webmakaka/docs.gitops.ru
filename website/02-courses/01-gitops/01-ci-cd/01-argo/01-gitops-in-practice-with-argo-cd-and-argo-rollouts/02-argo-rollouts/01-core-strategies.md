---
layout: page
title: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Core Strategies
description: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Core Strategies
keywords: courses, gitops, argo, GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Core Strategies
permalink: /courses/gitops/ci-cd/argo/gitops-in-practice-with-argo-cd-and-argo-rollouts/argo-rollouts/core-strategies/
---

# [Lauro Fialho Müller] GitOps in Practice with Argo CD and Argo Rollouts [ENG, 2026]: Argo Rollouts: Core Strategies

<br/>

**Делаю:**  
2026.01.29

<br/>

### Blue-Green Deployments

https://github.com/lm-academy/argo-rollouts-course/tree/main/blue-green

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: bluegreen-lab
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: rollout-bluegreen-active
  namespace: bluegreen-lab
spec:
  type: NodePort
  ports:
    - port: 3000
      protocol: TCP
      name: http
  selector:
    app: rollout-bluegreen
---
apiVersion: v1
kind: Service
metadata:
  name: rollout-bluegreen-preview
  namespace: bluegreen-lab
spec:
  type: NodePort
  ports:
    - port: 3000
      protocol: TCP
      name: http
  selector:
    app: rollout-bluegreen
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-bluegreen
  namespace: bluegreen-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: rollout-bluegreen
  template:
    metadata:
      labels:
        app: rollout-bluegreen
    spec:
      containers:
        - name: app
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: 'blue'
  strategy:
    blueGreen:
      activeService: rollout-bluegreen-active
      previewService: rollout-bluegreen-preview
      autoPromotionEnabled: false
EOF
```

<br/>

```
$ kubectl argo rollouts get rollout rollout-bluegreen -n bluegreen-lab
Name:            rollout-bluegreen
Namespace:       bluegreen-lab
Status:          ✔ Healthy
Strategy:        BlueGreen
Images:          lmacademy/simple-color-app:1.0.0 (stable, active)
Replicas:
  Desired:       5
  Current:       5
  Updated:       5
  Ready:         5
  Available:     5

NAME                                           KIND        STATUS     AGE  INFO
⟳ rollout-bluegreen                            Rollout     ✔ Healthy  17m
└──# revision:1
   └──⧉ rollout-bluegreen-78bd5bfc4d           ReplicaSet  ✔ Healthy  17m  stable,active
      ├──□ rollout-bluegreen-78bd5bfc4d-5bt42  Pod         ✔ Running  17m  ready:1/1
      ├──□ rollout-bluegreen-78bd5bfc4d-njdlm  Pod         ✔ Running  17m  ready:1/1
      ├──□ rollout-bluegreen-78bd5bfc4d-tf8b2  Pod         ✔ Running  17m  ready:1/1
      ├──□ rollout-bluegreen-78bd5bfc4d-tz8q6  Pod         ✔ Running  17m  ready:1/1
      └──□ rollout-bluegreen-78bd5bfc4d-vm4h6  Pod         ✔ Running  17m  ready:1/1
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-bluegreen
  namespace: bluegreen-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: rollout-bluegreen
  template:
    metadata:
      labels:
        app: rollout-bluegreen
    spec:
      containers:
        - name: app
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: 'green'
  strategy:
    blueGreen:
      activeService: rollout-bluegreen-active
      previewService: rollout-bluegreen-preview
      autoPromotionEnabled: false
EOF
```

<br/>

```
$ kubectl argo rollouts get rollout rollout-bluegreen -n bluegreen-lab
Name:            rollout-bluegreen
Namespace:       bluegreen-lab
Status:          ॥ Paused
Message:         BlueGreenPause
Strategy:        BlueGreen
Images:          lmacademy/simple-color-app:1.0.0 (active, preview, stable)
Replicas:
  Desired:       5
  Current:       10
  Updated:       5
  Ready:         5
  Available:     5

NAME                                           KIND        STATUS     AGE  INFO
⟳ rollout-bluegreen                            Rollout     ॥ Paused   24m
├──# revision:2
│  └──⧉ rollout-bluegreen-7f7bb56c9            ReplicaSet  ✔ Healthy  15s  preview
│     ├──□ rollout-bluegreen-7f7bb56c9-9rq7d   Pod         ✔ Running  15s  ready:1/1
│     ├──□ rollout-bluegreen-7f7bb56c9-fhvgb   Pod         ✔ Running  15s  ready:1/1
│     ├──□ rollout-bluegreen-7f7bb56c9-hg45c   Pod         ✔ Running  15s  ready:1/1
│     ├──□ rollout-bluegreen-7f7bb56c9-scf59   Pod         ✔ Running  15s  ready:1/1
│     └──□ rollout-bluegreen-7f7bb56c9-vbkwx   Pod         ✔ Running  15s  ready:1/1
└──# revision:1
   └──⧉ rollout-bluegreen-78bd5bfc4d           ReplicaSet  ✔ Healthy  24m  stable,active
      ├──□ rollout-bluegreen-78bd5bfc4d-5bt42  Pod         ✔ Running  24m  ready:1/1
      ├──□ rollout-bluegreen-78bd5bfc4d-njdlm  Pod         ✔ Running  24m  ready:1/1
      ├──□ rollout-bluegreen-78bd5bfc4d-tf8b2  Pod         ✔ Running  24m  ready:1/1
      ├──□ rollout-bluegreen-78bd5bfc4d-tz8q6  Pod         ✔ Running  24m  ready:1/1
      └──□ rollout-bluegreen-78bd5bfc4d-vm4h6  Pod         ✔ Running  24m  ready:1/1
```

<br/>

```
http://localhost:3100/rollouts/bluegreen-lab
```

<br/>

```
$ kubectl port-forward svc/rollout-bluegreen-active -n bluegreen-lab 3001:3000
$ kubectl port-forward svc/rollout-bluegreen-preview -n bluegreen-lab 3002:3000
```

<br/>

```
http://localhost:3001
http://localhost:3002
```

<br/>

```
$ kubectl argo rollouts promote rollout-bluegreen -n bluegreen-lab
```

<br/>

### Canary Deployments

<br/>

https://github.com/lm-academy/argo-rollouts-course/tree/main/canary

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: canary-lab
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: rollout-canary-public
  namespace: canary-lab
spec:
  type: NodePort
  ports:
    - port: 3000
      name: http
  selector:
    app: rollout-canary
---
apiVersion: v1
kind: Service
metadata:
  name: rollout-canary-stable
  namespace: canary-lab
spec:
  type: NodePort
  ports:
    - port: 3000
      name: http
  selector:
    app: rollout-canary
---
apiVersion: v1
kind: Service
metadata:
  name: rollout-canary-preview
  namespace: canary-lab
spec:
  type: NodePort
  ports:
    - port: 3000
      name: http
  selector:
    app: rollout-canary
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-canary
  namespace: canary-lab
spec:
  replicas: 10
  selector:
    matchLabels:
      app: rollout-canary
  template:
    metadata:
      labels:
        app: rollout-canary
    spec:
      containers:
        - name: rollout-canary
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: 'blue'
  strategy:
    canary:
      canaryService: rollout-canary-preview
      stableService: rollout-canary-stable
      steps:
        - setWeight: 20
        - pause: {}
        - setWeight: 50
        - pause:
            duration: 30s
EOF
```

<br/>

```
$ kubectl get svc -n canary-lab
NAME                     TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
rollout-canary-preview   NodePort   10.96.53.213    <none>        3000:31746/TCP   11m
rollout-canary-public    NodePort   10.96.173.245   <none>        3000:32148/TCP   11m
rollout-canary-stable    NodePort   10.96.35.165    <none>        3000:32094/TCP   11m
```

<br/>

```
http://localhost:3100/rollouts/canary-lab
```

<br/>

```
$ kubectl argo rollouts get rollout rollout-canary -n canary-lab
Name:            rollout-canary
Namespace:       canary-lab
Status:          ✔ Healthy
Strategy:        Canary
  Step:          4/4
  SetWeight:     100
  ActualWeight:  100
Images:          lmacademy/simple-color-app:1.0.0 (stable)
Replicas:
  Desired:       10
  Current:       10
  Updated:       10
  Ready:         10
  Available:     10

NAME                                        KIND        STATUS     AGE  INFO
⟳ rollout-canary                            Rollout     ✔ Healthy  61s
└──# revision:1
   └──⧉ rollout-canary-5c8bf656db           ReplicaSet  ✔ Healthy  61s  stable
      ├──□ rollout-canary-5c8bf656db-2c8mm  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-4jmd6  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-bsfsr  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-cz8mq  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-hnc9c  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-hv9hw  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-q5rqt  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-rhffj  Pod         ✔ Running  61s  ready:1/1
      ├──□ rollout-canary-5c8bf656db-wwwqh  Pod         ✔ Running  61s  ready:1/1
      └──□ rollout-canary-5c8bf656db-x687t  Pod         ✔ Running  61s  ready:1/1
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-canary
  namespace: canary-lab
spec:
  replicas: 10
  selector:
    matchLabels:
      app: rollout-canary
  template:
    metadata:
      labels:
        app: rollout-canary
    spec:
      containers:
        - name: rollout-canary
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: 'green'
  strategy:
    canary:
      canaryService: rollout-canary-preview
      stableService: rollout-canary-stable
      steps:
        - setWeight: 20
        - pause: {}
        - setWeight: 50
        - pause:
            duration: 30s
EOF
```

<br/>

```
$ kubectl port-forward svc/rollout-canary-public -n canary-lab 3000:3000
```

<br/>

```
http://localhost:3000
```

<br/>

```
// Не меняется. Ожидал, что будет отдавать часть
$ ./test-requests.sh http://localhost:3000/ -1 0.2
```

<br/>

```
$ kubectl argo rollouts get rollout rollout-canary -n canary-lab
Name:            rollout-canary
Namespace:       canary-lab
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/4
  SetWeight:     20
  ActualWeight:  20
Images:          lmacademy/simple-color-app:1.0.0 (canary, stable)
Replicas:
  Desired:       10
  Current:       10
  Updated:       2
  Ready:         10
  Available:     10

NAME                                        KIND        STATUS     AGE   INFO
⟳ rollout-canary                            Rollout     ॥ Paused   45m
├──# revision:2
│  └──⧉ rollout-canary-6d79bd67cd           ReplicaSet  ✔ Healthy  6m1s  canary
│     ├──□ rollout-canary-6d79bd67cd-n5n9f  Pod         ✔ Running  6m1s  ready:1/1
│     └──□ rollout-canary-6d79bd67cd-slfmx  Pod         ✔ Running  6m1s  ready:1/1
└──# revision:1
   └──⧉ rollout-canary-5c8bf656db           ReplicaSet  ✔ Healthy  45m   stable
      ├──□ rollout-canary-5c8bf656db-2c8mm  Pod         ✔ Running  45m   ready:1/1
      ├──□ rollout-canary-5c8bf656db-4jmd6  Pod         ✔ Running  45m   ready:1/1
      ├──□ rollout-canary-5c8bf656db-bsfsr  Pod         ✔ Running  45m   ready:1/1
      ├──□ rollout-canary-5c8bf656db-cz8mq  Pod         ✔ Running  45m   ready:1/1
      ├──□ rollout-canary-5c8bf656db-hnc9c  Pod         ✔ Running  45m   ready:1/1
      ├──□ rollout-canary-5c8bf656db-q5rqt  Pod         ✔ Running  45m   ready:1/1
      ├──□ rollout-canary-5c8bf656db-rhffj  Pod         ✔ Running  45m   ready:1/1
      └──□ rollout-canary-5c8bf656db-x687t  Pod         ✔ Running  45m   ready:1/1

```

<br/>

```
$ kubectl argo rollouts promote rollout-canary -n canary-lab
```
