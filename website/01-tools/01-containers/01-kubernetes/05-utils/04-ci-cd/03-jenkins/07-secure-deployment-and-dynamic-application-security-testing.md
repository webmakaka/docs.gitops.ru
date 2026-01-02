---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/secure-deployment-and-dynamic-application-security-testing/
---

# Secure Deployment and Dynamic Application Security Testing DAST

<br/>

**Делаю:**  
2026.01.02

<br/>

С помощью Argo мы запускаем в pipeline синхронизацию. С помощью zaproxy мы тестим приложение делая к нему запросы похожие на пользовательские.

<br/>

### [Устанавливаю ArgoCD](/tools/containers/kubernetes/utils/ci-cd/argo/argo-cd/setup/minikube/minikube/helm/)

<br/>

```
$ kubectl create ns dev
```

<br/>

В репо в каталог deploy кладу манифесты:

<br/>

**dso-demo-deploy.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: dso-demo
  name: dso-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dso-demo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: dso-demo
    spec:
      containers:
        - image: webmakaka/dso-demo
          name: dso-demo
          ports:
            - containerPort: 8080
          resources: {}
status: {}
```

<br/>

**dso-demo-svc.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: dso-demo
  name: dso-demo
spec:
  ports:
    - name: '8080'
      nodePort: 30080
      port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
    app: dso-demo
  type: NodePort
status:
  loadBalancer: {}
```

<br/>

```
ArgocD -> Settings -> Project -> New Project

Name: devsecops
Description : DevSecOps Demo Project

Once created, select project by name devsecops and edit the following ,

- SOURCE REPOSITORIES
- DESTINATIONS
- CLUSTER RESOURCE ALLOW LIST

When you edit you typically see an option with add button, use that to whitelist all (\*), and save each of the options.
```

<br/>

```
Applications -> New App

Application Name: dso-demo
Project Name: devsecops
Sync Policy : Manual

From Source

Repository URL: https://github.com/wildmakaka/dso-demo.git
Revision: main
Path: deploy

From Destination,

Cluster URL : https://kubernetes.default.svc (default)
Namespace : dev

Create

Click on SYNC
```

<br/>

```
$ kubectl get pods -n dev
NAME                        READY   STATUS    RESTARTS   AGE
dso-demo-794d8d5d9f-fjgpt   1/1     Running   0          90s
```

<br/>

```
$ kubectl get svc -n dev
NAME       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
dso-demo   NodePort   10.106.81.134   <none>        8080:30080/TCP   113s
```

<br/>

```
// OK!
http://192.168.49.2:30080/
```

<br/>

### Defining Policies to allow Jenkins to Remotely Deploy

```
$ argocd account list
NAME   ENABLED  CAPABILITIES
admin  true     login
```

<br/>

```yaml
$ kubectl patch cm -n argocd argocd-cm --patch "$(cat <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  accounts.jenkins: apiKey
  accounts.jenkins.enabled: "true"
EOF
)"
```

<br/>

```
$ argocd account list
NAME     ENABLED  CAPABILITIES
admin    true     login
jenkins  true     apiKey
```

<br/>

```
$ kubectl describe cm -n argocd argocd-cm
```

<br/>

```yaml
$ cat > jenkins.argorbacpolicy.csv <<EOF
p, role:deployer, applications, get, devsecops/*, allow
p, role:deployer, applications, sync, devsecops/*, allow
p, role:deployer, projects, get, devsecops, allow
g, jenkins, role:deployer
EOF
```

<br/>

```
$ argocd admin settings rbac validate --policy-file jenkins.argorbacpolicy.csv
```

```
$ argocd admin settings rbac can jenkins get applications devsecops/dso-demo --policy-file jenkins.argorbacpolicy.csv

$ argocd admin settings rbac can jenkins delete applications devsecops/dso-demo --policy-file jenkins.argorbacpolicy.csv

$ argocd admin settings rbac can jenkins sync applications devsecops/dso-demo --policy-file jenkins.argorbacpolicy.csv

$ argocd admin settings rbac can jenkins get projects devsecops --policy-file jenkins.argorbacpolicy.csv
```

<br/>

```yaml
$ kubectl patch cm -n argocd argocd-rbac-cm --patch "$(cat <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    p, role:deployer, applications, get, devsecops/*, allow
    p, role:deployer, applications, sync, devsecops/*, allow
    p, role:deployer, projects, get, devsecops, allow
    g, jenkins, role:deployer
EOF
)"
```

<br/>

```
$ kubectl describe cm -n argocd argocd-rbac-cm
```

<br/>

```
$ argocd account generate-token --account jenkins
```

<br/>

```
$ export AUTH_TOKEN=TOKEN
```

<br/>

```
// Validate by running argocd CLI
$ argocd app sync dso-demo --insecure --server argocd.192.168.49.2.nip.io --auth-token ${AUTH_TOKEN}
```

<br/>

### Configure Jenkins to run Argo Sync

<br/>

```
// Добавьте в Jenkins:
// Jenkins → Manage Jenkins → Credentials → System → Global credentials → Add Credentials
http://192.168.49.2:30264/manage/credentials/store/system/domain/_/newCredentials
```

Configure as,

- kind: Secret Text
- Secret : Token Copied Above
- ID: argocd-jenkins-deployer-token
- Description : argocd-jenkins-deployer-token

<br/>

**Jenkinsfile**

```
pipeline {
    environment {
        ARGO_SERVER = 'argocd.192.168.49.2.nip.io'
    }
    agent {
        kubernetes {
            yamlFile 'build-agent.yaml'
            defaultContainer 'maven'
            idleMinutes 1
        }
    }
}
```

<br/>

```
stage('Deploy to Dev') {
    environment {
        AUTH_TOKEN = credentials('argocd-jenkins-deployer-token')
    }
    steps {
        container('docker-tools') {
            sh '''
                docker run -t schoolofdevops/argocd-cli argocd app sync dso-demo \
                    --insecure --server $ARGO_SERVER --auth-token $AUTH_TOKEN

                docker run -t schoolofdevops/argocd-cli argocd app wait dso-demo \
                    --health --timeout 300 \
                    --insecure --server $ARGO_SERVER --auth-token $AUTH_TOKEN
            '''
        }
    }
}
```

<br/>

### Running a Dynamic Analysis with OWASP ZAP

```
pipeline {
    environment {
        ARGO_SERVER = 'argocd.192.168.49.2.nip.io'
        DEV_URL = 'http://192.168.49.2:30080/'
    }
}
```

<br/>

```
stage('Dynamic Analysis') {
    parallel {
        stage('E2E tests') {
            steps {
                sh 'echo "All Tests passed!!!"'
            }
        }
        stage('DAST') {
            steps {
                container('docker-tools') {
                    sh '''
                        docker run -t zaproxy/zap-stable zap-baseline.py -t $DEV_URL || exit 0
                    '''
                }
            }
        }
    }
}
```
