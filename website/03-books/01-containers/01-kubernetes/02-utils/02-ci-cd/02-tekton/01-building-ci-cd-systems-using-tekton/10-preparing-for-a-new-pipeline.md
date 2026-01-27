---
layout: page
title: Building CI/CD Systems Using Tekton - Preparing for a New Pipeline
description: Building CI/CD Systems Using Tekton - Preparing for a New Pipeline
keywords: books, ci-cd, tekton, Preparing for a New Pipeline
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/preparing-for-a-new-pipeline/
---

# [OK!] Chapter 12. Preparing for a New Pipeline

<br/>

**Делаю:**  
2025.12.13

<br/>

Ничего интересного. Здесь просто запускаем приложение без использования Tekton. Просто собираем в контейнере и запускаем в kubernetes.

<br/>

### Exploring the source code

<br/>

**Форкаем**

<br/>

https://github.com/PacktPublishing/tekton-book-app

<br/>

Finally, you need to make one last adjustment to your cluster to be able to deploy your applications automatically. You will need to give the appropriate role to your service account so that it can access the Kubernetes API and automatically update your application. You can use the following command to do so:

<br/>

```
$ kubectl create clusterrolebinding \
  serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin \
  --group=system:serviceaccounts
```

<br/>

```
$ cd ~/tmp/
$ git clone https://github.com/<YOUR_USERNAME>/tekton-book-app
```

<br/>

```
$ cd tekton-book-app
```

<br/>

```
$ npm install
$ npm run lint
$ npm run test
$ npm start
```

<br/>

```
$ curl localhost:3000
$ curl localhost:3000/add/12/10
$ curl localhost:3000/substract/10/2
```

<br/>

### Building and deploying the application

<br/>

```
$ export DOCKER_USERNAME=<YOUR_USERNAME>
$ docker build -t ${DOCKER_USERNAME}/tekton-lab-app .
$ docker login docker.io
$ docker push ${DOCKER_USERNAME}/tekton-lab-app
```

<br/>

### Deploying the application

<br/>

```
$ echo ${DOCKER_USERNAME}
```

**Не забыть заменить <DOCKER_USERNAME> на свой.**

<br/>

```yaml
$ cat << 'EOF' | envsubst | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tekton-deployment
spec:
  selector:
    matchLabels:
      app: trigger-demo
  template:
    metadata:
      labels:
        app: trigger-demo
    spec:
      containers:
      - name: tekton-pod
        image: ${DOCKER_USERNAME}/tekton-lab-app
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: tekton-svc
spec:
  selector:
    app: trigger-demo
  ports:
  - port: 3000
    protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-ingress
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: tekton-svc
            port:
              number: 3000
EOF
```

<br/>

```
$ kubectl get pods
NAME                                 READY   STATUS    RESTARTS   AGE
tekton-deployment-5d5d5fd747-9dcn4   1/1     Running   0          78s
```

<br/>

```
// Убеждаемся, что значение профиля установлено
$ echo ${PROFILE}
```

<br/>

```
$ curl $(minikube --profile ${PROFILE} ip)/add/12/10 -jq
{"result":22}
```

<br/>

OK!

<br/>

Далее нудная процедура по изменению кода и обновлению всего и вся, чтобы показать нам как все это нудно делать руками.
