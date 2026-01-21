---
layout: page
title: Implementing Canary Release for Prod
description: Implementing Canary Release for Prod
keywords: devops, containers, kubernetes, argo, rollouts, setup, canary
permalink: /courses/gitops/tools/argo/ultimate-argo-bootcamp-by-school-of-devops/argo-rollouts/canary-strategy/
---

# [School Of DevOps] Ultimate Argo Bootcamp: Implementing Canary Release for Prod

<br/>

Делаю:  
2026.01.21

<br/>

```
$ mkdir -p ~/tmp/labs/
$ cd ~/tmp/labs/
$ git clone https://github.com/sfd226/argo-labs
```

<br/>

```
$ kubectl create ns prod
```

<br/>

```
$ kubectl config set-context --current --namespace=prod
```

<br/>

```
$ kubectl config get-contexts
```

<br/>

### Prepare Prod Environment

```
$ cd argo-labs/
```

<br/>

```
$ rm base/deployment.yaml
```

<br/>

```yaml
$ cat << EOF > base/rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  labels:
    app: vote
    tier: front
  name: vote
spec:
  replicas: 4
  selector:
    matchLabels:
      app: vote
  strategy:
    blueGreen:
      autoPromotionEnabled: true
      autoPromotionSeconds: 30
      activeService: vote
      previewService: vote-preview
  template:
    metadata:
      labels:
        app: vote
        tier: front
    spec:
      containers:
      - image: schoolofdevops/vote:v1
        name: vote
        imagePullPolicy: Always
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "250m"
            memory: "128Mi"
EOF
```

<br/>

```yaml
$ cat << EOF > base/preview-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: vote-preview
  labels:
    role: vote
spec:
  selector:
    app: vote
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
      nodePort: 30100
  type: NodePort
EOF
```

<br/>

```yaml
$ cat << EOF > base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- rollout.yaml
- service.yaml
- preview-service.yaml
EOF
```

<br/>

```
$ mkdir prod
```

<br/>

```yaml
$ cat << EOF > prod/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: vote
spec:
  ports:
    - name: "80"
      nodePort: 30200
      port: 80
      protocol: TCP
      targetPort: 80
  type: NodePort
EOF
```

<br/>

```yaml
$ cat << EOF > prod/preview-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: vote-preview
spec:
  ports:
    - name: "80"
      nodePort: 30300
      port: 80
      protocol: TCP
      targetPort: 80
  type: NodePort
EOF
```

<br/>

```yaml
$ cat << EOF > prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
namespace: prod
commonAnnotations:
  supported-by: sre@example.com
labels:
- includeSelectors: false
  pairs:
    project: instavote
patches:
- path: service.yaml
- path: preview-service.yaml
EOF
```

<br/>

```
$ kustomize build prod
```

<br/>

```
$ kubectl apply -k prod/
```

<br/>

```
$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
vote-7f7d9f97bf-bgk26   1/1     Running   0          16s
vote-7f7d9f97bf-gdv4v   1/1     Running   0          16s
vote-7f7d9f97bf-h98jf   1/1     Running   0          16s
vote-7f7d9f97bf-mjw2m   1/1     Running   0          16s
```

<br/>

### Create Canary Release

<br/>

```yaml
$ cat << EOF > prod/rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: vote
spec:
  replicas: 5
  strategy:
    blueGreen: null
    canary:
      steps:
      - setWeight: 20
      - pause:
          duration: 10s
      - setWeight: 40
      - pause:
          duration: 10s
      - setWeight: 60
      - pause:
          duration: 10s
      - setWeight: 80
      - pause:
          duration: 10s
      - setWeight: 100
EOF
```

<br/>

```yaml
$ cat << EOF > prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
namespace: prod
commonAnnotations:
  supported-by: sre@example.com
labels:
- includeSelectors: false
  pairs:
    project: instavote
patches:
- path: service.yaml
- path: preview-service.yaml
- path: rollout.yaml
EOF
```

<br/>

```
$ kustomize build prod
```

<br/>

```
$ kubectl apply -k prod/
```

<br/>

```
$ kubectl argo rollouts dashboard -p 3100
```

<br/>

```
http://localhost:3100
```

<br/>

```
$ vi base/rollout.yaml
```

<br/>

Прописываю image:

```
spec:
  containers:
  - image: schoolofdevops/vote:v2
```

<br/>

```
$ kubectl apply -k prod
```

<br/>

```
$ kubectl argo rollouts status vote
Paused - CanaryPauseStep
Progressing - more replicas need to be updated
Paused - CanaryPauseStep
Progressing - more replicas need to be updated
Paused - CanaryPauseStep
Progressing - more replicas need to be updated
Paused - CanaryPauseStep
Progressing - more replicas need to be updated
Progressing - updated replicas are still becoming available
Progressing - waiting for all steps to complete
Healthy
```

<br/>

```
$ kubectl argo rollouts get rollout vote
Name:            vote
Namespace:       prod
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          7/9
  SetWeight:     80
  ActualWeight:  80
Images:          schoolofdevops/vote:v1 (stable)
                 schoolofdevops/vote:v2 (canary)
Replicas:
  Desired:       5
  Current:       5
  Updated:       4
  Ready:         5
  Available:     5

NAME                              KIND        STATUS     AGE    INFO
⟳ vote                            Rollout     ॥ Paused   3m48s
├──# revision:2
│  └──⧉ vote-6fd5d7d96d           ReplicaSet  ✔ Healthy  46s    canary
│     ├──□ vote-6fd5d7d96d-9hnlw  Pod         ✔ Running  46s    ready:1/1
│     ├──□ vote-6fd5d7d96d-njzdq  Pod         ✔ Running  33s    ready:1/1
│     ├──□ vote-6fd5d7d96d-mqd76  Pod         ✔ Running  21s    ready:1/1
│     └──□ vote-6fd5d7d96d-llnfz  Pod         ✔ Running  9s     ready:1/1
└──# revision:1
   └──⧉ vote-7f7d9f97bf           ReplicaSet  ✔ Healthy  3m48s  stable
      └──□ vote-7f7d9f97bf-d4c8s  Pod         ✔ Running  3m48s  ready:1/1
```

<br/>

```
$ kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME           ENDPOINTS                                                  AGE
vote           10.244.0.22:80,10.244.0.24:80,10.244.0.25:80 + 1 more...   6h42m
vote-preview   10.244.0.22:80,10.244.0.24:80,10.244.0.25:80 + 1 more...   6h42m
```

<!-- <br/>

### Getting Ready to add Traffic Management - Set up Nginx Ingress Controller

```
$ helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.hostPort.enabled=true \
  --set controller.service.type=NodePort \
  --set controller.hostPort.ports.http=80 \
  --set-string controller.nodeSelector."kubernetes\.io/os"=linux \
  --set-string controller.nodeSelector.ingress-ready="true"
```

<br/>

```
$ kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-7b9d96d5f6-ssgs2   0/1     Pending   0          8s
```

<br/>

В состоянии pending, пока не установить label

<br/>

```
$ kubectl label node kind-worker ingress-ready="true"
```

<br/>

```
$ kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-7b9d96d5f6-ssgs2   1/1     Running   0          105s
``` -->

<br/>

### Add Ingress Rule with Host based Routing

```yaml
$ cat << EOF > prod/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vote
  namespace: prod
spec:
  ingressClassName: nginx
  rules:
  - host: 127.0.0.1.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: vote
            port:
              number: 80
EOF
```

<!-- <br/>

```yaml
$ cat << EOF > prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
- ingress.yaml
EOF
``` -->

<br/>

```yaml
$ cat << EOF > prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
- ingress.yaml
namespace: prod
commonAnnotations:
  supported-by: sre@example.com
labels:
- includeSelectors: false
  pairs:
    project: instavote
patches:
- path: service.yaml
- path: preview-service.yaml
- path: rollout.yaml
EOF
```

<br/>

```
$ kubectl apply -k prod
```

<br/>

```
$ kubectl get ing
NAME   CLASS   HOSTS              ADDRESS         PORTS   AGE
vote   nginx   127.0.0.1.nip.io   10.96.228.163   80      2m
```

<br/>

```
$ kubectl describe ing vote
```

<br/>

```
// OK!
http://127.0.0.1.nip.io/
```

<br/>

### Canary with Traffic Routing

<br/>

```yaml
$ cat << EOF > prod/rollout.yaml
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
      trafficRouting:
        nginx:
          stableIngress: vote
      steps:
      - setCanaryScale:
          replicas: 3
      - setWeight: 20
      - pause:
          duration: 10s
      - setWeight: 40
      - pause:
          duration: 10s
      - setWeight: 60
      - pause:
          duration: 10s
      - setWeight: 80
      - pause:
          duration: 10s
      - setWeight: 100
EOF
```

<br/>

```
$ kubectl apply -k prod/
```

<br/>

Поменять image tag

```
$ vi base/rollout.yaml
```

<br/>

```
$ kubectl apply -k prod
```

<br/>

```
$ kubectl get ing
NAME               CLASS   HOSTS              ADDRESS        PORTS   AGE
vote               nginx   127.0.0.1.nip.io   10.96.215.21   80      8m12s
vote-vote-canary   nginx   127.0.0.1.nip.io   10.96.215.21   80      2m51s
```

<br/>

```
$ kubectl describe ing vote-vote-canary
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
Name:             vote-vote-canary
Labels:           <none>
Namespace:        prod
Address:          10.96.215.21
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host              Path  Backends
  ----              ----  --------
  127.0.0.1.nip.io
                    /   vote-preview:80 (10.244.0.50:80,10.244.0.51:80,10.244.0.52:80)
Annotations:        nginx.ingress.kubernetes.io/canary: true
                    nginx.ingress.kubernetes.io/canary-weight: 40
Events:
  Type    Reason  Age                 From                      Message
  ----    ------  ----                ----                      -------
  Normal  Sync    6s (x4 over 2m23s)  nginx-ingress-controller  Scheduled for sync
```

<br/>

http://localhost:3100/rollouts/rollout/prod/vote
