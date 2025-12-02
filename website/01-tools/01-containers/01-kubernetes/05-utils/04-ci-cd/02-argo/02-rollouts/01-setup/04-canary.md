---
layout: page
title: Implementing Canary Release for Prod
description: Implementing Canary Release for Prod
keywords: devops, containers, kubernetes, argo, rollouts, setup, canary
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/rollouts/canary/
---

# Implementing Canary Release for Prod

<br/>

Взято в курсе "[Udemy] Ultimate Argo Bootcamp by School of Devops [ENG, 2024]"

<br/>

Делаю:  
2024.12.22

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
$ cp -r staging prod
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

add this rollout overlay spec to prod/kustomization.yaml in patches section as:

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
```

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

<br/>

```yaml
$ cat << EOF > prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
- ingress.yaml
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
$ kubectl describe ing vote-vote-canary
```

<br/>

http://localhost:3100/rollouts/rollout/prod/vote

<br/>

Запутался, где что и пока не хочется разбираться.
