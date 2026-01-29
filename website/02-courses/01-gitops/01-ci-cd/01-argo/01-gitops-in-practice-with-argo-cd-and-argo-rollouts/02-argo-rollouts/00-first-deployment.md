---
layout: page
title: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - First Deployment
description: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - First Deployment
keywords: courses, gitops, argo, GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - First Deployment
permalink: /courses/gitops/ci-cd/argo/gitops-in-practice-with-argo-cd-and-argo-rollouts/argo-rollouts/first-deployment/
---

# [Lauro Fialho Müller] GitOps in Practice with Argo CD and Argo Rollouts [ENG, 2026]: Argo Rollouts: First Deployment

<br/>

**Делаю:**  
2026.01.29

<br/>

https://github.com/lm-academy/argo-rollouts-course/tree/main/first-rollout

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: simple-color-app
spec:
  replicas: 5
  selector:
    matchLabels:
      app: simple-color-app
  strategy:
    canary:
      steps:
        - setWeight: 20
        - pause: {}
  template:
    metadata:
      labels:
        app: simple-color-app
    spec:
      containers:
        - name: app
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: 'orange'
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: simple-color-app
spec:
  type: NodePort
  ports:
    - port: 3000
      targetPort: 3000
  selector:
    app: simple-color-app
EOF
```

<br/>

```
$ kubectl argo rollouts list rollouts
```

<br/>

```
$ kubectl argo rollouts get rollout simple-color-app
```

<br/>

```
http://localhost:3100/rollouts/default
```

<br/>

```
$ kubectl port-forward svc/simple-color-app -n default 3000:3000
```

<br/>

```
http://localhost:3000/
```

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/lm-academy/argo-rollouts-course.git
$ cd argo-rollouts-course
$ ./test-requests.sh http://localhost:3000/ 10
```

<br/>

```
🚀 Sending requests to http://localhost:3000/ (Count: 10, Sleep: 0.5s)
---------------------------------------------------
[1] Response: Rollout Demo: orange
[2] Response: Rollout Demo: orange
[3] Response: Rollout Demo: orange
[4] Response: Rollout Demo: orange
[5] Response: Rollout Demo: orange
[6] Response: Rollout Demo: orange
[7] Response: Rollout Demo: orange
[8] Response: Rollout Demo: orange
[9] Response: Rollout Demo: orange
[10] Response: Rollout Demo: orange
---------------------------------------------------
Done.
```

<br/>

```
$ ./test-requests.sh http://localhost:3000/ -1 0.2
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: simple-color-app
spec:
  replicas: 5
  selector:
    matchLabels:
      app: simple-color-app
  strategy:
    canary:
      steps:
        - setWeight: 20
        - pause: {}
  template:
    metadata:
      labels:
        app: simple-color-app
    spec:
      containers:
        - name: app
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: 'purple'
EOF
```

<br/>

```
$ kubectl argo rollouts get rollout simple-color-app
```

<br/>

```
$ kubectl argo rollouts promote simple-color-app
```
