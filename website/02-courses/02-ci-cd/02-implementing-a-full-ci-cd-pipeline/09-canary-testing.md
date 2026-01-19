---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Канареечное тестирование
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Канареечное тестирование
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Канареечное тестирование
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/canary-testing/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 11. Канареечное тестирование

https://github.com/linuxacademy/cicd-pipeline-train-schedule-canary

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: train-schedule-service-stable
spec:
  type: NodePort
  selector:
    app: train-schedule
    track: stable
  ports:
  - protocol: TCP
    port: 8080
    nodePort: 30003

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: train-schedule-deployment-stable
  labels:
    app: train-schedule
spec:
  replicas: 2
  selector:
    matchLabels:
      app: train-schedule
      track: stable
  template:
    metadata:
      labels:
        app: train-schedule
        track: stable
    spec:
      containers:
      - name: train-schedule
        image: linuxacademycontent/train-schedule:1
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 15
          timeoutSeconds: 1
          periodSeconds: 10
        resources:
          requests:
            cpu: 200m
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: train-schedule-service-canary
spec:
  type: NodePort
  selector:
    app: train-schedule
    track: canary
  ports:
  - protocol: TCP
    port: 8080
    nodePort: 30004

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: train-schedule-deployment-canary
  labels:
    app: train-schedule
spec:
  replicas: 1
  selector:
    matchLabels:
      app: train-schedule
      track: canary
  template:
    metadata:
      labels:
        app: train-schedule
        track: canary
    spec:
      containers:
      - name: train-schedule
        image: linuxacademycontent/train-schedule:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 15
          timeoutSeconds: 1
          periodSeconds: 10
        resources:
          requests:
            cpu: 200m
EOF
```

<br/>

    $ kubectl get pods
    NAME                                                READY   STATUS    RESTARTS   AGE
    train-schedule-deployment-canary-5687c545db-9ddtn   1/1     Running   0          5s
    train-schedule-deployment-stable-67c59b7745-gz7r6   1/1     Running   0          12s
    train-schedule-deployment-stable-67c59b7745-m52r9   1/1     Running   0          12s

<br/>

http://node1.k8s:30003/
http://node1.k8s:30004/

<br/>

    $ kubectl delete deployment train-schedule-deployment-stable
    $ kubectl delete svc train-schedule-service-stable

<br/>

    $ kubectl delete deployment train-schedule-deployment-canary
    $ kubectl delete svc train-schedule-service-canary

<br/>

**В файле:**

https://github.com/linuxacademy/cicd-pipeline-train-schedule-canary/blob/example-solution/Jenkinsfile

Заменить willbla на свою учетную запись в hub.docker.com
