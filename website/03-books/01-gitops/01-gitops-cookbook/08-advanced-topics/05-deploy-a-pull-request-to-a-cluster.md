---
layout: page
title: GitOps Cookbook - Advanced Topics - Deploy a Pull Request to a Cluster
description: При создании pull request деплоить preview приложения
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Deploy a Pull Request to a Cluster
permalink: /books/gitops/gitops-cookbook/advanced-topics/deploy-a-pull-request-to-a-cluster/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 08. Advanced Topics: 8.5 Deploy a Pull Request to a Cluster

<br/>

**Задача:**  
При создании pull request деплоить preview приложения

<br/>

**Делаю:**  
2025.12.10

<br/>

```
// Смотрим актуальную версию API
$ kubectl api-resources | grep ApplicationSet
applicationsets                     appset,appsets     argoproj.io/v1alpha1              true         ApplicationSet
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: myapps
  namespace: argocd
spec:
  generators:
    - pullRequest:
        github:
          owner: wildmakaka
          repo: gitops-cookbook-sc
          labels:
            - preview
        requeueAfterSeconds: 60
  template:
    metadata:
      name: 'myapp-{{branch}}-{{number}}'
    spec:
      source:
        repoURL: 'https://github.com/wildmakaka/gitops-cookbook-sc.git'
        targetRevision: '{{head_sha}}'
        path: ch08/bgd-pr
      project: default
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{branch}}-{{number}}'
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: github-token
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  token: YOUR_GITHUB_PERSONAL_ACCESS_TOKEN_HERE
EOF
```

<br/>

Создал label: preview

<br/>

Create a pull request against the repository and label it with preview.

Wait for one minute until the ApplicationSet detects the change and creates the Application object.

<br/>

```
$ kubectl logs deployment/argocd-applicationset-controller -n argocd --since=1m --tail=50
time="2025-12-10T02:37:31Z" level=info msg="generated 1 applications" applicationset=argocd/myapps
time="2025-12-10T02:37:31Z" level=info msg="end reconcile in 369.360017ms" applicationset=argocd/myapps requeueAfter=1m0s
```

<br/>

```
$ kubectl describe applicationset myapps -n argocd
Name:         myapps
Namespace:    argocd
Labels:       <none>
Annotations:  <none>
API Version:  argoproj.io/v1alpha1
Kind:         ApplicationSet
Metadata:
  Creation Timestamp:  2025-12-10T02:36:30Z
  Generation:          1
  Resource Version:    14221
  UID:                 a80bfdb5-d38e-4786-a8da-dbf72f2ac7bc
Spec:
  Generators:
    Pull Request:
      Github:
        Labels:
          preview
        Owner:                wildmakaka
        Repo:                 gitops-cookbook-sc
      Requeue After Seconds:  60
  Template:
    Metadata:
      Name:  myapp-{{branch}}-{{number}}
    Spec:
      Destination:
        Namespace:  {{branch}}-{{number}}
        Server:     https://kubernetes.default.svc
      Project:      default
      Source:
        Path:             ch08/bgd-pr
        Repo URL:         https://github.com/wildmakaka/gitops-cookbook-sc.git
        Target Revision:  {{head_sha}}
Status:
  Conditions:
    Last Transition Time:  2025-12-10T02:36:31Z
    Message:               All applications have been generated successfully
    Reason:                ApplicationSetUpToDate
    Status:                False
    Type:                  ErrorOccurred
    Last Transition Time:  2025-12-10T02:36:31Z
    Message:               Successfully generated parameters for all Applications
    Reason:                ParametersGenerated
    Status:                True
    Type:                  ParametersGenerated
    Last Transition Time:  2025-12-10T02:36:31Z
    Message:               All applications have been generated successfully
    Reason:                ApplicationSetUpToDate
    Status:                True
    Type:                  ResourcesUpToDate
Events:
  Type    Reason   Age   From                       Message
  ----    ------   ----  ----                       -------
  Normal  created  32s   applicationset-controller  created Application "myapp-test-2"

```

<br/>

```
$ argocd app list
NAME                 CLUSTER                         NAMESPACE  PROJECT  STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                  PATH         TARGET
argocd/myapp-test-2  https://kubernetes.default.svc  test-2     default  OutOfSync  Missing  Manual      <none>      https://github.com/wildmakaka/gitops-cookbook-sc.git  ch08/bgd-pr  547e746bef9a5663c90ebf02df1608b9a67ba204
```

<br/>

```
$ argocd app get myapp-test-2
Name:               argocd/myapp-test-2
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          test-2
URL:                http://argocd.192.168.49.2.nip.io/applications/myapp-test-2
Source:
- Repo:             https://github.com/wildmakaka/gitops-cookbook-sc.git
  Target:           547e746bef9a5663c90ebf02df1608b9a67ba204
  Path:             ch08/bgd-pr
SyncWindow:         Sync Allowed
Sync Policy:        Manual
Sync Status:        OutOfSync from 547e746bef9a5663c90ebf02df1608b9a67ba204
Health Status:      Missing

GROUP  KIND        NAMESPACE  NAME  STATUS     HEALTH   HOOK  MESSAGE
apps   Deployment  test-2     bgd   OutOfSync  Missing
```

<br/>

```
$ kubectl create ns test-2
namespace/test-2 created
```

<br/>

```
$ argocd app sync myapp-test-2
TIMESTAMP                  GROUP        KIND   NAMESPACE                  NAME    STATUS   HEALTH            HOOK  MESSAGE
2025-12-10T05:43:31+03:00   apps  Deployment      test-2                   bgd    Synced  Progressing
2025-12-10T05:43:31+03:00   apps  Deployment      test-2                   bgd    Synced  Progressing              deployment.apps/bgd unchanged

Name:               argocd/myapp-test-2
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          test-2
URL:                http://argocd.192.168.49.2.nip.io/applications/myapp-test-2
Source:
- Repo:             https://github.com/wildmakaka/gitops-cookbook-sc.git
  Target:           547e746bef9a5663c90ebf02df1608b9a67ba204
  Path:             ch08/bgd-pr
SyncWindow:         Sync Allowed
Sync Policy:        Manual
Sync Status:        Synced to 547e746bef9a5663c90ebf02df1608b9a67ba204
Health Status:      Progressing

Operation:          Sync
Sync Revision:      547e746bef9a5663c90ebf02df1608b9a67ba204
Phase:              Succeeded
Start:              2025-12-10 05:43:31 +0300 MSK
Finished:           2025-12-10 05:43:31 +0300 MSK
Duration:           0s
Message:            successfully synced (all tasks run)

GROUP  KIND        NAMESPACE  NAME  STATUS  HEALTH       HOOK  MESSAGE
apps   Deployment  test-2     bgd   Synced  Progressing        deployment.apps/bgd unchanged
```

<br/>

```
$ kubectl get pods -n test-2
NAME                   READY   STATUS    RESTARTS   AGE
bgd-5b6b49dcf9-5bbcs   1/1     Running   0          46s
```

<br/>

Закрываю MR.

Спустя минуту приложение пропало.
