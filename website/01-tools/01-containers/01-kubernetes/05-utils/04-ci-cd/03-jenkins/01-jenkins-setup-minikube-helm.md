---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/setup/minikube/helm/
---

# Инсталляция Jenkins в ubuntu 22.04

<br/>

**Делаю:**  
2026.01.01

<br/>

### Инсталляция Jenkins с помощью helm

```
$ helm repo add jenkins https://charts.jenkins.io
$ helm repo update
```

<br/>

```
$ kubectl create namespace ci
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > jenkins.values.yaml <<EOF
controller:
  serviceType: NodePort
  resources:
    requests:
      cpu: "400m"
      memory: "512Mi"
    limits:
      cpu: "2000m"
      memory: "4096Mi"
  testEnabled: true
EOF
```

<br/>

```
$ helm install --namespace ci --values jenkins.values.yaml jenkins jenkins/jenkins
```

<br/>

```
$ helm list -n ci
NAME   	NAMESPACE	REVISION	UPDATED                                STATUS  	CHART          	APP VERSION
jenkins	ci       	1       	2025-12-26 06:17:51.564382494 +0300 MSKdeployed	jenkins-5.8.114	2.528.3
```

<br/>

```
$ kubectl get pods -n ci
NAME        READY   STATUS    RESTARTS   AGE
jenkins-0   2/2     Running   0          3m13s
```

<br/>

```
// Get your 'admin' user password by running:
$ kubectl exec --namespace ci -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

или

$ kubectl get secret -n ci jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

<br/>

```
$ export PROFILE=${USER}-minikube
$ minikube --profile ${PROFILE} ip
192.168.49.2
```

<br/>

```
$ kubectl get svc -n ci
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
jenkins         NodePort    10.96.201.220   <none>        8080:30264/TCP   2m19s
jenkins-agent   ClusterIP   10.102.17.14    <none>        50000/TCP        2m19s
```

<br/>

```
$ kubectl -n ci patch svc jenkins -p '{"spec":{"ports":[{"port":8080,"nodePort":30264}]}}'
```

<br/>

```
// admin
http://192.168.49.2:30264
```

<br/>

### Install Essential Plugins

Browse to Manage Jenkins -> Manage Plugins -> Available

http://192.168.49.2:30264/manage/pluginManager/available

- Blue Ocean
- Configuration as Code Plugin - Groovy Scripting Extension

<br/>

### Создание учетки для работы с GitHub

```
Personal Access Token (PAT)

Создайте PAT в GitHub:

Settings → Developer settings → Personal access tokens → Fine-grained tokens

Или: Settings → Developer settings → Personal access tokens → Tokens (classic)

Дайте права: repo, admin:repo_hook, read:user
```

<br/>

```
Добавьте в Jenkins:

Jenkins → Manage Jenkins → Credentials → System → Global credentials → Add Credentials

Kind: "Username with password"

Username: ваш GitHub username

Password: ваш PAT

ID: github-token (или любое другое имя)
```
