---
layout: page
title: Инсталляция Argo Rollouts в kind
description: Инсталляция Argo Rollouts в kind
keywords: devops, containers, kubernetes, argo, rollouts, setup, minikube
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argo-rollouts/setup/
---

# Инсталляция Argo Rollouts в kind

<br/>

Делаю:  
2026.01.19

### [CLI Argo Rollouts](/tools/containers/kubernetes/utils/ci-cd/argo/argo-rollouts/setup/cli/)

<br/>

```
$ kubectl create namespace argo-rollouts
$ kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

<br/>

```
$ kubectl api-resources | grep -i argo
analysisruns                        ar                 argoproj.io/v1alpha1              true         AnalysisRun
analysistemplates                   at                 argoproj.io/v1alpha1              true         AnalysisTemplate
applications                        app,apps           argoproj.io/v1alpha1              true         Application
applicationsets                     appset,appsets     argoproj.io/v1alpha1              true         ApplicationSet
appprojects                         appproj,appprojs   argoproj.io/v1alpha1              true         AppProject
clusteranalysistemplates            cat                argoproj.io/v1alpha1              false        ClusterAnalysisTemplate
experiments                         exp                argoproj.io/v1alpha1              true         Experiment
rollouts                            ro                 argoproj.io/v1alpha1              true         Rollout
```

<br/>

```
$ kubectl get pods -n argo-rollouts
NAME                             READY   STATUS    RESTARTS   AGE
argo-rollouts-6f4f78ffd8-n6425   1/1     Running   0          65s
```
