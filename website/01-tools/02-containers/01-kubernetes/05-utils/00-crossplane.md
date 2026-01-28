---
layout: page
title: Crossplane
description: Crossplane
keywords: gitops, containers, Crossplane
permalink: /tools/containers/kubernetes/utils/crossplane/
---

# Crossplane

<br/>

**Делаю:**  
2025.12.20

<br/>

### Устанавливаем crossplane

<br/>

```
$ helm repo add crossplane-stable https://charts.crossplane.io/stable
$ helm repo update


$ helm search repo crossplane-stable
NAME                        	CHART VERSION	APP VERSION	DESCRIPTION
crossplane-stable/crossplane	2.1.3        	2.1.3      	Crossplane is an open source Kubernetes add-on ...


// Устанавливаем Crossplane
$ helm install crossplane crossplane-stable/crossplane \
 --namespace crossplane-system \
 --create-namespace \
 --version 2.1.3 \
 --wait \
 --timeout 15m
```

<br/>

```
$ kubectl get pods -n crossplane-system
NAME                                       READY   STATUS    RESTARTS   AGE
crossplane-844dd5d9b-s48qm                 1/1     Running   0          3m47s
crossplane-rbac-manager-7b4c99b894-jbnzz   1/1     Running   0          3m47s
```

<br/>

```
$ kubectl api-resources  | grep crossplane
compositeresourcedefinitions        xrd,xrds     apiextensions.crossplane.io/v2         false        CompositeResourceDefinition
compositionrevisions                comprev      apiextensions.crossplane.io/v1         false        CompositionRevision
compositions                        comp         apiextensions.crossplane.io/v1         false        Composition
environmentconfigs                  envcfg       apiextensions.crossplane.io/v1beta1    false        EnvironmentConfig
managedresourceactivationpolicies   mrap         apiextensions.crossplane.io/v1alpha1   false        ManagedResourceActivationPolicy
managedresourcedefinitions          mrd,mrds     apiextensions.crossplane.io/v1alpha1   false        ManagedResourceDefinition
usages                                           apiextensions.crossplane.io/v1beta1    false        Usage
providerconfigs                                  helm.crossplane.io/v1beta1             false        ProviderConfig
cronoperations                      cronops      ops.crossplane.io/v1alpha1             false        CronOperation
operations                          ops          ops.crossplane.io/v1alpha1             false        Operation
watchoperations                     watchops     ops.crossplane.io/v1alpha1             false        WatchOperation
configurationrevisions                           pkg.crossplane.io/v1                   false        ConfigurationRevision
configurations                                   pkg.crossplane.io/v1                   false        Configuration
deploymentruntimeconfigs                         pkg.crossplane.io/v1beta1              false        DeploymentRuntimeConfig
functionrevisions                                pkg.crossplane.io/v1                   false        FunctionRevision
functions                                        pkg.crossplane.io/v1                   false        Function
imageconfigs                                     pkg.crossplane.io/v1beta1              false        ImageConfig
locks                                            pkg.crossplane.io/v1beta1              false        Lock
providerrevisions                                pkg.crossplane.io/v1                   false        ProviderRevision
providers                                        pkg.crossplane.io/v1                   false        Provider
clusterusages                                    protection.crossplane.io/v1beta1       false        ClusterUsage
usages                                           protection.crossplane.io/v1beta1       true         Usage
```

<br/>

// providers
https://marketplace.upbound.io/providers

<!-- <br/>

### Шаг 1: Установка provider-helm

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: crossplane-contrib-provider-helm
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-helm:v1.0.6
EOF
```

<br/>

```
$ kubectl get providers
NAME                               INSTALLED   HEALTHY   PACKAGE                                                   AGE
crossplane-contrib-provider-helm   True        True      xpkg.upbound.io/crossplane-contrib/provider-helm:v1.0.6   6m16s
```

<br/>

```
$ kubectl get pods -n crossplane-system | grep helm
crossplane-contrib-provider-helm-9a0591f0f59e-858c9fbfc8-n9zk7   1/1     Running   0             39s
```

===============================

<br/>

### Шаг 2: Сначала создадим ProviderConfig для Helm

<br/>

```yaml
$ cat <<EOF | kubectl apply -f -
apiVersion: helm.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: InjectedIdentity
EOF
```

<br/>

### Шаг 3: Создадим простой Helm Release (nginx)

<br/>

```yaml
$ cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helm-provider-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: crossplane-contrib-provider-helm-9a0591f0f59e
  namespace: crossplane-system
EOF
```

<br/>

```yaml
$ cat <<EOF | kubectl apply -f -
apiVersion: helm.crossplane.io/v1beta1
kind: Release

EOF
```

<br/>

```
$ kubectl get release
```

<br/>

```
// $ kubectl delete release
$ kubectl describe release argcd
``` -->
