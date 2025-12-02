---
layout: page
title: GitOps Cookbook - Cloud Native CI/CD - Tekton - Deploy an Application to Kubernetes Using a Tekton Task
description: GitOps Cookbook - Cloud Native CI/CD - Tekton - Deploy an Application to Kubernetes Using a Tekton Task
keywords: books, gitops, cloud-native-cicd, tekton, Deploy an Application to Kubernetes Using a Tekton Task
permalink: /books/gitops/gitops-cookbook/cloud-native-cicd/tekton/deploy-an-application-to-kubernetes-using-a-tekton-task/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 06. Cloud Native CI/CD: Tekton: 6.6 Deploy an Application to Kubernetes Using a Tekton Task

<br/>

Запускаем шагом ранее созданный image в kubernetes

<br/>

Делаю:  
2025.12.02

<br/>

```
$ kubectl create serviceaccount tekton-deployer-sa
```

<br/>

**Define a Role named pipeline-role for the ServiceAccount**

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: task-role
rules:
  - apiGroups:
      - ""
    resources:
      - pods
      - services
      - endpoints
      - configmaps
      - secrets
    verbs:
      - "*"
  - apiGroups:
      - apps
    resources:
      - deployments
      - replicasets
    verbs:
      - "*"
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - get
  - apiGroups:
      - apps
    resources:
      - replicasets
    verbs:
      - get
EOF
```

<br/>

**Bind the Role to the ServiceAccount**

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: task-role-binding
roleRef:
  kind: Role
  name: task-role
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: tekton-deployer-sa
EOF
```

<br/>

**Define a Task**

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: kubectl
spec:
  params:
    - name: SCRIPT
      description: The kubectl CLI arguments to run
      type: string
      default: "kubectl help"
  steps:
    - name: oc
      image: quay.io/openshift/origin-cli:latest
      script: |
        #!/usr/bin/env bash
        $(params.SCRIPT)
EOF
```

<br/>

**Define a TaskRun**

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: kubectl-taskrun
spec:
  serviceAccountName: tekton-deployer-sa
  taskRef:
    name: kubectl
  params:
    - name: SCRIPT
      value: |
        kubectl create deploy tekton-greeter --image=webmakaka/tekton-greeter:latest
EOF
```

<br/>

```
// wait for 30 sec
$ tkn taskrun logs kubectl-taskrun -f

***
[oc] deployment.apps/tekton-greeter created
```

<br/>

```
$ kubectl get deploy
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
tekton-greeter   1/1     1            1           50s
```

<br/>

```
$ kubectl expose deploy/tekton-greeter --port 8080
$ kubectl port-forward svc/tekton-greeter 8080:8080
```

<br/>

```
$ curl localhost:8080
Meeow!! from Tekton 😺🚀⏎
```
