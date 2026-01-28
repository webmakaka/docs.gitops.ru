---
layout: page
title: GitOps Days 2021 Handling Dependencies with Flux
description: GitOps Days 2021 Handling Dependencies with Flux
keywords: linux, kubernetes, FluxCD, Kustomize, GitOps Days 2021 Handling Dependencies with Flux
permalink: /courses/gitops/ci-cd/fluxcd/gitops-days-2021-handling-dependencies-with-flux/
---

# [YouTube] GitOps Days 2021 Handling Dependencies with Flux - Jason Morgan

https://www.youtube.com/watch?v=laMwuG8r7Tw

<br/>

[Инсталляция Linkerd](//docs.k8s.ru/tools/containers/kubernetes/utils/service-mesh/linkerd/setup/)

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/BuoyantIO/gitops_examples
```

<br/>

```
$ kubectl apply -f gitops_examples/flux/runtime/manifests/runtime_git.yaml
```

<br/>

```
$ kubectl get gitrepositories -A
NAMESPACE     NAME     URL                                                READY   STATUS                                                            AGE
flux-system   gitops   https://github.com/BuoyantIO/gitops_examples.git   True    Fetched revision: main/6bcab49784782321cfd688592822b10f6673365f   4m25s
```

<br/>

```
$ kubectl apply -f gitops_examples/flux/runtime/manifests/dev_cluster.yaml
```

<br/>

```
$ watch kubectl get kustomizations.kustomize.toolkit.fluxcd.io -A
```

<br/>

```
$ linkerd check
$ linkerd viz check
```

<br/>

```
$ kubectl apply -f gitops_examples/flux/apps/manifests/podinfo.yaml
```

<br/>

```
$ linkerd viz dashboard
```

<br/>

```
$ kubectl port-forward svc/frontend 8080:8080
```

<br/>

```
$ vi gitops_examples/flux/apps/source/podinfo/patch.yaml
```

<br/>

меняем цвет

<br/>

git add / git commit / git push

<br/>

```
$ flux reconcile kustomization podinfo
```

<br/>

```
$ linkerd viz dashboard
```

<br/>

Обратить внимание на Traffic Splits
