---
layout: page
title: GitOps Cookbook - Cloud Native CI/CD - Tekton - Update a Kubernetes Resource Using Helm and Create a Pull Request
description: GitOps Cookbook - Cloud Native CI/CD - Tekton - Update a Kubernetes Resource Using Helm and Create a Pull Request
keywords: books, gitops, cloud-native-cicd, tekton, Update a Kubernetes Resource Using Helm and Create a Pull Request
permalink: /books/gitops/gitops-cookbook/cloud-native-cicd/tekton/update-a-kubernetes-resource-using-helm-and-create-a-pull-request/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 06. Cloud Native CI/CD: Tekton: 6.10 Update a Kubernetes Resource Using Helm and Create a Pull Request

<br/>

**Задача:**  
Обновить deployment приложения задеплоенного с помощью Helm с помощью Tekton Pipeline

<br/>

**Делаю:**  
2025.12.03

<br/>

```
$ tkn hub install task helm-upgrade-from-repo
```

<br/>

```
$ helm repo add gitops-cookbook https://gitops-cookbook.github.io/helm-charts/
```

<br/>

```
$ helm install pacman gitops-cookbook/pacman
```

```
NAME: pacman
LAST DEPLOYED: Wed Dec  3 06:49:06 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

<br/>

```
$ kubectl get pods -l=app.kubernetes.io/name=pacman
NAME                      READY   STATUS    RESTARTS   AGE
pacman-86454cc887-qhrpl   1/1     Running   0          8m
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: helm-pacman-run-
spec:
  serviceAccountName: tekton-deployer-sa
  taskRef:
    name: helm-upgrade-from-repo
  params:
    - name: helm_repo
      value: https://gitops-cookbook.github.io/helm-charts/
    - name: chart_name
      value: gitops-cookbook/pacman
    - name: release_version
      value: 0.1.0
    - name: release_name
      value: pacman
    - name: overwrite_values
      value: replicaCount=2
EOF
```

<br/>

```
$ tkn taskrun logs -f
```

<br/>

```
$ kubectl get deploy -l=app.kubernetes.io/name=pacman
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
pacman   2/2     2            2           11m
```
