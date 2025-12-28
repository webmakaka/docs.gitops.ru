---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/setup/minikube/minikube/helm/
---

# Инсталляция Jenkins в ubuntu 22.04

<br/>

**Делаю:**  
2025.12.26

<br/>

### Скачать image заранее

```
$ eval $(minikube --profile ${PROFILE} docker-env)


$ {
    docker pull maven:3.8.6-openjdk-11
    docker pull gcr.io/kaniko-project/executor:v1.19.2-debug
    docker pull jenkins/inbound-agent:latest
    docker pull rmkanda/docker-tools:latest
    docker pull rmkanda/trufflehog
    docker pull licensefinder/license_finder
}
```

<br/>

### Инсталляция Jenkins с помощью helm

```
$ helm repo add jenkins https://charts.jenkins.io
$ helm repo update
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
$ kubectl patch svc jenkins -p '{"spec":{"ports":[{"port":8080,"nodePort":30264}]}}'
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

### Launch a DevOps Continuous Integration Pipeline

fork -> https://github.com/lfs262/dso-demo

<br/>

В pom обновить

```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>12.1.0</version>
</plugin>
```

<br/>

```
Personal Access Token (PAT)

Создайте PAT в GitHub:

Settings → Developer settings → Personal access tokens → Fine-grained tokens

Или: Settings → Developer settings → Personal access tokens → Tokens (classic)

Дайте права: repo, admin:repo_hook, read:user


Добавьте в Jenkins:

Jenkins → Manage Jenkins → Credentials → System → Global credentials → Add Credentials

Kind: "Username with password"

Username: ваш GitHub username

Password: ваш PAT

ID: github-token (или любое другое имя)
```

<br/>

Blue Ocean -> Create a new Pipeline

<br/>

```
// Долго перестодавал и запускаскал поды
$ kubectl get pods -n ci
NAME                                READY   STATUS              RESTARTS      AGE
dso-demo-main-1-g5w63-9rp1g-723hv   0/5     ContainerCreating   0             4s
jenkins-0                           2/2     Running             1 (33m ago)   48m
```

<br/>

Settings -> Scan Repository Triggers -> Periodically if not otherwise run -> interval -> 1 minute

<br/>

### Adding Docker Build and Publish Stage

<br/>

```
$ {
    export REGISTRY_SERVER=https://index.docker.io/v1/
    export REGISTRY_USER=webmakaka
    export REGISTRY_PASSWORD=webmakaka-password

    echo ${REGISTRY_SERVER}
    echo ${REGISTRY_USER}
    echo ${REGISTRY_PASSWORD}
}
```

<br/>

```
$ kubectl create secret -n ci docker-registry regcred \
    --docker-server=${REGISTRY_SERVER} \
    --docker-username=${REGISTRY_USER} \
    --docker-password=${REGISTRY_PASSWORD}
```

<br/>

**build-agent.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: spring-build-ci
spec:
  containers:
    # Обязательный контейнер для подключения к Jenkins
    - name: jnlp
      image: jenkins/inbound-agent:latest
      args: ['$(JENKINS_SECRET)', '$(JENKINS_NAME)']
      volumeMounts:
        - name: workspace
          mountPath: /home/jenkins/agent

    - name: maven
      image: maven:3.8.6-openjdk-11
      command: ['cat']
      tty: true
      volumeMounts:
        - name: m2
          mountPath: /root/.m2/
        - name: workspace
          mountPath: /home/jenkins/agent

    - name: kaniko
      # image: gcr.io/kaniko-project/executor:v1.6.0-debug
      image: gcr.io/kaniko-project/executor:v1.19.2-debug
      command: ['sleep']
      args: ['999999']
      volumeMounts:
        - name: jenkins-docker-cfg
          mountPath: /kaniko/.docker
        - name: workspace
          mountPath: /home/jenkins/agent

    # Опциональные контейнеры (можно удалить если не используются)
    - name: docker-tools
      image: rmkanda/docker-tools:latest
      command: ['cat']
      tty: true
      volumeMounts:
        - name: workspace
          mountPath: /home/jenkins/agent

    - name: trufflehog
      image: rmkanda/trufflehog
      command: ['cat']
      tty: true
      volumeMounts:
        - name: workspace
          mountPath: /home/jenkins/agent

    - name: licensefinder
      image: licensefinder/license_finder
      command: ['cat']
      tty: true
      volumeMounts:
        - name: workspace
          mountPath: /home/jenkins/agent

  volumes:
    # Используем emptyDir вместо hostPath для переносимости
    - name: m2
      emptyDir: {}

    # Workspace volume (обязательный)
    - name: workspace
      emptyDir: {}

    # Docker registry credentials
    - name: jenkins-docker-cfg
      projected:
        sources:
          - secret:
              name: regcred
              items:
                - key: .dockerconfigjson
                  path: config.json

    # Опциональные volumes
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock

    - name: trivycache
      emptyDir: {}
```

<br/>

// webmakaka на свой нужно поменять.
Jenkinsfile

```
pipeline {
  agent {
    kubernetes {
      yamlFile 'build-agent.yaml'
      defaultContainer 'maven'
      idleMinutes 1
    }
  }
  stages {
    stage('Build') {
      parallel {
        stage('Compile') {
          steps {
            container('maven') {
              sh 'mvn compile'
            }
          }
        }
      }
    }
    stage('Test') {
      parallel {
        stage('Unit Tests') {
          steps {
            container('maven') {
              sh 'mvn test'
            }
          }
        }
      }
    }
    stage('Package') {
      steps {
        container('maven') {
          sh 'mvn package -DskipTests'
        }
      }
    }
    stage('Build and Push Docker Image') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=docker.io/webmakaka/dso-demo'
        }
      }
    }
  }
}
```
