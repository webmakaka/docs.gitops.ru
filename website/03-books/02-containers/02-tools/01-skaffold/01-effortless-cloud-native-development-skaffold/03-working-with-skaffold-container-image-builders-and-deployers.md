---
layout: page
title: Building CI/CD Systems Using Tekton - Working with Skaffold Container Image Builders and Deployers
description: Building CI/CD Systems Using Tekton - Working with Skaffold Container Image Builders and Deployers
keywords: books, ci-cd, tekton, Working with Skaffold Container Image Builders and Deployers
permalink: /books/containers/kubernetes/tools/skaffold/working-with-skaffold-container-image-builders-and-deployers/
---

# Chapter 6. Working with Skaffold Container Image Builders and Deployers

<br/>

**Делаю:**  
2025.12.14

<br/>

### docker

<br/>

```
$ cd ~/tmp/Effortless-Cloud-Native-App-Development-Using-Skaffold/Chapter06/
$ skaffold run --profile docker
```

<br/>

```
$ kubectl get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/reactive-web-app-5b4f98987b-9bpxp   1/1     Running   0          2m14s

NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/kubernetes         ClusterIP      10.96.0.1       <none>        443/TCP          35m
service/reactive-web-app   LoadBalancer   10.106.199.20   <pending>     8080:31242/TCP   2m14s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/reactive-web-app   1/1     1            1           2m14s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/reactive-web-app-5b4f98987b   1         1         1       2m14s
```

<br/>

```
$ kubectl get svc
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes         ClusterIP      10.96.0.1       <none>        443/TCP          36m
reactive-web-app   LoadBalancer   10.106.199.20   <pending>     8080:31242/TCP   2m30s
```

```
$ export \
    PROFILE=${USER}-minikube
```

<br/>

```
// Перестало отображаться в новых версиях
$ minikube --profile ${PROFILE} service reactive-web-app
|-----------|------------------|-------------|---------------------------|
| NAMESPACE |       NAME       | TARGET PORT |            URL            |
|-----------|------------------|-------------|---------------------------|
| default   | reactive-web-app |        8080 | http://192.168.49.2:31242 |
|-----------|------------------|-------------|---------------------------|
🎉  Opening service default/reactive-web-app in default browser...


// Но можно
$ minikube --profile ${PROFILE} service --all
```

<br/>

```
$ curl -X GET "http://192.168.49.2:31242/employee" \
  | jq
```

<br/>

```
[
  {
    "id": 1,
    "firstName": "Peter",
    "lastName": "Parker",
    "age": 25,
    "salary": 20000
  },
  {
    "id": 2,
    "firstName": "Tony",
    "lastName": "Stark",
    "age": 30,
    "salary": 40000
  },
  {
    "id": 3,
    "firstName": "Clark",
    "lastName": "Kent",
    "age": 31,
    "salary": 60000
  },
  {
    "id": 4,
    "firstName": "Bruce",
    "lastName": "Wayne",
    "age": 33,
    "salary": 100000
  }
]
```

<br/>

```
$ skaffold delete
```

<br/>

### Jib and Helm

<br/>

Helm установлен

<br/>

```
// Проверка, что проект билдится
// Нет необходимости выполнять
$ ./mvnw package
```

<br/>

```
$ vi pom.xml
```

<br/>

Прописываю подходящую версию библиотеки jib-maven-plugin

<br/>

```xml
<groupId>com.google.cloud.tools</groupId>
<artifactId>jib-maven-plugin</artifactId>
<version>3.4.0</version>
```

<br/>

Если протухнет, смотреть здесь:

https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#quickstart

<br/>

```
$ skaffold run --profile jibWithHelm
```

<br/>

```
$ skaffold delete --profile jibWithHelm
```

<br/>

### Kustomize

<br/>

```
$ skaffold dev
```

<br/>

```
$ skaffold run --profile=kustomizeBase --default-repo=gcr.io/basic-curve-316617
$ skaffold run --profile=kustomizeProd --default-repo=gcr.io/basic-curve-316617
```

<br/>

```
$ skaffold delete
```

<br/>

```
$ skaffold run --profile=kustomizeDev
```

<br/>

```
$ echo $PROFILE
marley-minikube
$ eval $(minikube -p ${PROFILE} docker-env)
```

<br/>

Fail!
