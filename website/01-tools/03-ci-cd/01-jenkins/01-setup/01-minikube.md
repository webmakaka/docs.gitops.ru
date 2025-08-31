---
layout: page
title: Инсталляция Jenkins в Minikube с помощью Helm
description: Инсталляция Jenkins в Minikube с помощью Helm
keywords: tools, ci-cd, jenkins, setup, minikube, helm
permalink: /tools/ci-cd/jenkins/setup/minikube/
---

# Инсталляция Jenkins в Minikube с помощью Helm

<br/>

Делаю:  
2024.11.23

<br/>

P.S. Не разобрался как работать с docker в данном конкретном случае!
Менял агенты, все равно получал ошибку.

<br/>

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

<br/>

Дока:  
https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3

<br/>

```
$ helm repo add jenkinsci https://charts.jenkins.io
$ helm repo update
```

<br/>

```
$ helm search repo jenkinsci
NAME             	CHART VERSION	APP VERSION	DESCRIPTION
jenkinsci/jenkins	5.7.12       	2.479.1    	Jenkins - Build great things at any scale! As t...
```

<br/>

```
$ kubectl create namespace jenkins
```

<br/>

### Create a persistent volume

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
  namespace: jenkins
spec:
  storageClassName: jenkins-pv
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 20Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/jenkins-volume/
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: jenkins-pv
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
```

<br/>

```
$ export \
    PROFILE=${USER}-minikube
```

<br/>

```
// Не помню точно нужно это делать или нет
$ minikube ssh --profile ${PROFILE}
minikube:~$ sudo mkdir -p /data/jenkins-volume
minikube:~$ sudo chown -R 1000:1000 /data/jenkins-volume

^D
```

<br/>

### Create a service account

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: jenkins
rules:
- apiGroups:
  - '*'
  resources:
  - statefulsets
  - services
  - replicationcontrollers
  - replicasets
  - podtemplates
  - podsecuritypolicies
  - pods
  - pods/log
  - pods/exec
  - podpreset
  - poddisruptionbudget
  - persistentvolumes
  - persistentvolumeclaims
  - jobs
  - endpoints
  - deployments
  - deployments/scale
  - daemonsets
  - cronjobs
  - configmaps
  - namespaces
  - events
  - secrets
  verbs:
  - create
  - get
  - watch
  - delete
  - list
  - patch
  - update
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
  - list
  - watch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:jenkins
EOF
```

<br/>

### Install Jenkins

```
$ mkdir -p ~/tmp
$ cd ~/tmp
$ wget https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml -O jenkins-values.yaml
$ vi jenkins-values.yaml
```

<br/>

```
  storageClass: jenkins-pv
```

<br/>

```
serviceAccount:
  create: false
  name: jenkins
```

<br/>

```
$ helm install jenkins -n jenkins -f jenkins-values.yaml jenkinsci/jenkins

// uninstall
// $ helm uninstall jenkins -n jenkins
```

<!--

https://github.com/bitnami/charts/issues/6875

$ docker build -t myuser/jenkins:latest .
$ docker push myuser/jenkins:latest
helm install myjenkins --set image.repository=webmakaka/jenkins-docker --set image.tag=latest bitnami/jenkins



// $ helm install jenkins -n jenkins --set image.repository=webmakaka/jenkins-docker --set image.tag=latest -f jenkins-values.yaml jenkinsci/jenkins

$ helm install jenkins -n jenkins -f jenkins-values.yaml jenkinsci/jenkins



jenkins/jnlp-agent-docker

Планигы

Docker
Version1.7.0

Docker Pipeline
Version580.vc0c340686b_54



CloudBees Docker Build and Publish


https://www.jenkins.io/doc/book/pipeline/docker/




additionalAgents:
  docker1:
    podName: docker1
    customJenkinsLabels: docker1
    image:
      repository: webmakaka/jenkins-docker
      tag: latest


pipeline {
    agent {
        docker { image 'node:22.11.0-alpine3.20' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'node --version'
            }
        }
    }
}


dockerContainer
jenkins/inbound-agent:3273.v4cfe589b_fd83-1


jenkins/jnlp-agent-docker
latest
-->

<br/>

```
$ kubectl get pods -n jenkins
NAME        READY   STATUS    RESTARTS   AGE
jenkins-0   2/2     Running   0          7m45s
```

<br/>

### Вариант 1. Подключения с использованием обычного ingress

<br/>

```
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo ${INGRESS_HOST}
192.168.49.2
```

<br/>

```yaml
$ envsubst << 'EOF' | cat | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress-service
  namespace: jenkins
  annotations:
    nginx.ingress.kubernetes.io/default-backend: ingress-nginx-controller
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - host: ${INGRESS_HOST}.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: jenkins
            port:
              number: 8080
EOF
```

<br/>

```
$ kubectl get ingress -n jenkins
NAME                      CLASS    HOSTS                 ADDRESS        PORTS   AGE
jenkins-ingress-service   <none>   192.168.49.2.nip.io   192.168.49.2   80      27s
```

<br/>

Подкючаюсь: 192.168.49.2.nip.io

Заработало!

<br/>

### Вариант 2. Подключения с использованием ngrok ingress. Вариант когда нужно подключиться из интернета, а белого IP нет.

<br/>

### [Моя дока](//docs.k8s.ru//docs.k8s.ru/tools/containers/kubernetes/minikube/ngrok-ingress-controller/)

<br/>

```
// https://dashboard.ngrok.com/cloud-edge/domains - копируем домен
$ export NGROK_DOMAIN="hugely-amusing-owl.ngrok-free.app"
```

<br/>

Со следующим ingress

```yaml
$ envsubst << 'EOF' | cat | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ngrok-jenkins-ingress-service
  namespace: jenkins
spec:
  ingressClassName: ngrok
  rules:
    - host: ${NGROK_DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: jenkins
                port:
                  number: 8080
EOF
```

<br/>

Подкючаюсь: https://hugely-amusing-owl.ngrok-free.app

Заработало!

<br/>

### Получить пароль админа для логина в UI

```
// Get your 'admin' user password by running:
$ jsonpath="{.data.jenkins-admin-password}" secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
$ echo $(echo $secret | base64 --decode)
```

<!--

```
$ kubectl get pvc -n jenkins

$ helm list -n jenkins

kubectl get pod -n jenkins -oyaml | grep jenkins-claim -B2

https://github.com/IlyaKozak/rsschool-devops-course-config/pull/1

```

-->
