---
layout: page
title: Ultimate Argo Bootcamp - Blue Green Releases with Argo Rollouts
description: Ultimate Argo Bootcamp - Blue Green Releases with Argo Rollouts
keywords: courses, gitops, argo, Ultimate Argo Bootcamp, Blue Green Releases with Argo Rollouts
permalink: /courses/gitops/ci-cd/argo/ultimate-argo-bootcamp-by-school-of-devops/argo-rollouts/blue-green-deployment/
---

# [School Of DevOps] Ultimate Argo Bootcamp: Blue Green Releases with Argo Rollouts

<br/>

Делаю:  
2026.01.19

<br/>

### Сначала пример как можно делать без использования Argo Rollouts

<br/>

```
$ mkdir -p ~/tmp/labs/
$ cd ~/tmp/labs/
$ git clone https://github.com/sfd226/argo-labs
```

<br/>

```
$ kubectl create ns staging
```

<br/>

```
$ kubectl config set-context --current --namespace=staging
```

<br/>

```
$ kubectl config get-contexts
CURRENT   NAME                                CLUSTER                            AUTHINFO                            NAMESPACE
*         kind-kind                           kind-kind                          kind-kind                           staging
```

<br/>

```
$ cd argo-labs/
```

<br/>

```
$ kustomize build base
```

<br/>

```
$ kustomize build staging
```

<br/>

```
// Deploy vote service to staging
$ kubectl apply -k staging
```

<br/>

### Create a Preview Service

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
- deployment.yaml
- service.yaml
- preview-service.yaml
EOF
```

<br/>

```
$ kubectl apply -k staging
```

<br/>

```
$ kubectl describe svc vote
$ kubectl describe svc vote-preview
```

<br/>

```
$ kubectl port-forward svc/vote 30000:80
$ kubectl port-forward svc/vote-preview 30100:80
```

<br/>

```
http://localhost:30000/
http://localhost:30100/
```

<br/>

### Migrate Deployment to Argo Rollout

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

```yaml
$ cat << EOF > staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
namespace: staging
commonAnnotations:
  supported-by: sre@example.com
labels:
- includeSelectors: false
  pairs:
    project: instavote
patches:
- path: service.yaml
EOF
```

<br/>

```
$ kubectl delete deploy vote
```

<br/>

```
$ kubectl apply -k staging
```

<br/>

```
$ kubectl get ro
NAME   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
vote   4         4         4            4           93s
```

<br/>

```
$ kubectl describe ro vote
```

<br/>

```
http://localhost:30000/
http://localhost:30100/
```

<br/>

### Deploy a Blue/Green Release

Можно в UI посмотреть. Для этого:

```
$ kubectl argo rollouts dashboard -p 3100
```

<br/>

```
http://localhost:3100/rollouts
```

<br/>

```
$ vi base/rollout.yaml
```

<br/>

update

```
spec:
  containers:
  - image: schoolofdevops/vote:v2
```

<br/>

```
$ kubectl apply -k staging
```

<br/>

```
$ kubectl argo rollouts status vote
Healthy
```

<br/>

Можно в UI сделать Rollback
