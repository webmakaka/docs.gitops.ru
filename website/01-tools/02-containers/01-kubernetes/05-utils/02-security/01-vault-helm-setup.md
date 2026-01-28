---
layout: page
title: Vault
description: Vault
keywords: gitops, containers, vault
permalink: /tools/containers/kubernetes/utils/security/vault/setup/
---

# Vault

<br/>

**Делаю:**  
2026.01.04

<br/>

https://artifacthub.io/packages/helm/hashicorp/vault

<br/>

```
// Забанены для РФ
$ helm repo add hashicorp https://helm.releases.hashicorp.com
```

<!--
<br/>


```
$ helm repo update
```


<br/>

```
$ helm search repo vault
```

<br/>

```
$ helm install vault hashicorp/vault \
    -n vault \
    --create-namespace \
    --set server.dev.enabled=true \
    --version 5.8.115 \
    --wait \
    --timeout 15m
``` -->

<br/>

```
// Качаю по vpn
https://helm.releases.hashicorp.com/vault-0.31.0.tgz
```

<br/>

```
$ cd ~/tmp
```

<br/>

```
$ helm install vault ~/tmp/vault-0.31.0.tgz \
    -n vault \
    --create-namespace \
    --set server.dev.enabled=true \
    --wait \
    --timeout 15m
```

<br/>

```
$ helm list -n vault
NAME 	NAMESPACE	REVISION	UPDATED                                STATUS  	CHART       	APP VERSION
vault	vault    	1       	2026-01-04 08:07:16.571168714 +0300 MSKdeployed	vault-0.31.0	1.20.4
```

<br/>

```
$ kubectl get pods -n vault
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          7m20s
vault-agent-injector-556c5dd8fb-lctbq   1/1     Running   0          7m20s
```
